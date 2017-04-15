package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

const (
	AppName    = "Pingo"
	APIName    = "FindMyiphone"
	APIVertion = "2.0.2"
)

const (
	ExitOK = 0 + iota

	ExitError = 9 + iota
	ExitParseArgsError
	ExitRequestDeviceError
	ExitRequestSoundError
)

var HEADER_MAP = map[string][]string{
	"Content-Type":          {"application/json; charset=utf-8"},
	"X-Apple-Find-Api-Ver":  {"2.0"},
	"X-Apple-Authscheme":    {"UserIdGuest"},
	"X-Apple-Realm-Support": {"1.0"},
	"Accept-Language":       {"en-us"},
	"userAgent":             {"Pingo"},
	"Connection":            {"keep-alive"},
}

type ClientContext struct {
	AppName      string `json:"appName"`
	AppVersion   string `json:"appVersion"`
	ShouldLocate bool   `json:"shouldLocate"`
}

type SoundParams struct {
	ClientContext `json:"clientContext"`
	Device        string `json:"device"`
	Subject       string `json:"subject"`
}

type Container struct {
	Content []struct {
		DeviceName string `json:"deviceDisplayName"`
		DeviceId   string `json:"id"`
	} `json:"content"`
}

func main() {
	os.Exit(NewCLI().Run(os.Args))
}

type CLI struct {
	outStream, errStream io.Writer
}

func NewCLI() *CLI {
	return &CLI{
		outStream: os.Stdout,
		errStream: os.Stderr,
	}
}

func (cli *CLI) PutOutStream(format string, args ...interface{}) {
	fmt.Fprintf(cli.outStream, format, args...)
}

func (cli *CLI) PutErrStream(format string, args ...interface{}) {
	fmt.Fprintf(cli.errStream, format, args...)
}

func (cli *CLI) Run(args []string) int {
	appleAccount, err := cli.parseArgs(args)
	if err != nil {
		cli.PutErrStream("Failed to parse args:\n %s\n", err)
		return ExitParseArgsError
	}

	client := &Client{AppleAccount: appleAccount}

	deviceID, err := client.RequestDeviceID()
	if err != nil {
		cli.PutErrStream("Failed to request device id:\n %s\n", err)
		return ExitRequestDeviceError
	}

	if err = client.RequestSound(deviceID); err != nil {
		cli.PutErrStream("Failed to request sound:\n %s\n", err)
		return ExitRequestSoundError
	}

	return ExitOK
}

type AppleAccount struct {
	ID        string
	Pass      string
	ModelName string
}

func (cli *CLI) parseArgs(args []string) (*AppleAccount, error) {
	appleID := os.Getenv("APPLE_ID")
	applePass := os.Getenv("APPLE_PASSWORD")

	flags := flag.NewFlagSet(AppName, flag.ContinueOnError)

	flags.StringVar(&appleID, "apple-id", appleID, "apple id to use")
	flags.StringVar(&appleID, "i", appleID, "apple id to use (short)")
	flags.StringVar(&applePass, "apple-password", applePass, "apple passwaord to to")
	flags.StringVar(&applePass, "p", applePass, "apple passwaord to to (short)")

	if err := flags.Parse(args[1:]); err != nil {
		return nil, errors.New("Faild to parse flag")
	}

	if appleID == "" || applePass == "" {
		return nil, errors.New("APPLE ID or APPLE PASSWORD are empty")
	}

	modelName := flags.Arg(0)

	if modelName == "" {
		return nil, errors.New("Device model name is empty")
	}

	return &AppleAccount{ID: appleID, Pass: applePass, ModelName: modelName}, nil
}

type Client struct {
	*AppleAccount
	debug bool
}

func (c *Client) requestDeviceIDURL() string {
	return fmt.Sprintf("https://fmipmobile.icloud.com/fmipservice/device/%s/initClient", c.ModelName)
}

func (c *Client) requestSoundURL() string {
	return fmt.Sprintf("https://fmipmobile.icloud.com/fmipservice/device/%s/playSound", c.ModelName)
}

func (c *Client) RequestDeviceID() (string, error) {
	body, err := c.getBody("POST", c.requestDeviceIDURL(), nil)
	if err != nil {
		return "", errors.New("getBody: " + err.Error())
	}

	deviceID, err := c.parseDeviceID(body)
	if err != nil {
		return "", errors.New("parseDeviceID: " + err.Error())
	}

	return deviceID, nil
}

func (c *Client) getBody(method string, url string, params io.Reader) ([]byte, error) {
	resp, err := c.httpExecute(method, url, params)
	if err != nil {
		return nil, errors.New("httpExecute: " + err.Error())
	}

	bodyBytes, err := ioutil.ReadAll(resp.Body)
	defer resp.Body.Close()
	if err != nil {
		return nil, errors.New("ReadAll: " + err.Error())
	}

	if c.debug {
		fmt.Printf("STATUS: %s\n", resp.Status)
		fmt.Println("BODY RESPONSE: " + string(bodyBytes))
	}

	return bodyBytes, nil
}

type HTTPExecuteError struct {
	RequestHeaders    string
	ResponseBodyBytes []byte
	Status            string
	StatusCode        int
}

func (e HTTPExecuteError) Error() string {
	return "HTTP response is not 200/OK as expected. Actual response: \n" +
		"\tResponse Status: '" + e.Status + "'\n" +
		"\tResponse Code: " + strconv.Itoa(e.StatusCode) + "\n" +
		"\tRequest Headers: " + e.RequestHeaders + "\n" +
		"\tResponse Body: " + string(e.ResponseBodyBytes)
}

func (c *Client) httpExecute(method string, url string, body io.Reader) (*http.Response, error) {
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, errors.New("NewRequest: " + err.Error())
	}

	req.Header = http.Header(HEADER_MAP)
	req.SetBasicAuth(c.ID, c.Pass)

	client := &http.Client{Timeout: time.Duration(10 * time.Second)}

	if c.debug {
		fmt.Printf("Request: %v\n", req)
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, errors.New("Do: " + err.Error())
	}

	if resp.StatusCode != 200 {
		defer resp.Body.Close()
		bytes, _ := ioutil.ReadAll(resp.Body)

		debugHeader := ""
		for k, vals := range req.Header {
			for _, val := range vals {
				debugHeader += "[key: " + k + ", val: " + val + "]"
			}
		}

		return resp, HTTPExecuteError{
			RequestHeaders:    debugHeader,
			ResponseBodyBytes: bytes,
			Status:            resp.Status,
			StatusCode:        resp.StatusCode,
		}
	}

	return resp, nil
}

func (c *Client) parseDeviceID(body []byte) (string, error) {

	var cont Container
	if err := json.Unmarshal(body, &cont); err != nil {
		return "", errors.New("Unmarshal: " + err.Error())
	}

	var deviceId string
	for _, v := range cont.Content {
		if strings.HasSuffix(v.DeviceName, c.ModelName) {
			deviceId = v.DeviceId
			break
		}
	}

	if deviceId == "" {
		return "", errors.New("Not found device id")
	}

	return deviceId, nil
}

func (c *Client) RequestSound(deviceId string) error {
	input, err := json.Marshal(SoundParams{
		ClientContext: ClientContext{AppName: APIName, AppVersion: APIVertion},
		Device:        deviceId,
		Subject:       AppName,
	})

	if err != nil {
		return errors.New("json.Marshal: " + err.Error())
	}

	if _, err := c.getBody("POST", c.requestSoundURL(), bytes.NewBuffer(input)); err != nil {
		return errors.New("getBody: " + err.Error())
	}

	return nil
}

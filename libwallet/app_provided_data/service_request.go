package app_provided_data

type Session struct {
	ClientVersion              string
	ClientVersionName          string
	ClientSdkVersion           string
	Language                   string
	ClientType                 string
	AuthToken                  string
	BaseURL                    string
	BackgroundExecutionMetrics string
	DeviceToken                string
}

type HttpClientSessionProvider interface { //nolint:staticcheck // TODO: type HttpClientSessionProvider should be HTTPClientSessionProvider
	Session() (*Session, error)
	SetSessionStatus(status string)
	SetMinClientVersion(minClientVersion string)
	SetAuthToken(authToken string)
}

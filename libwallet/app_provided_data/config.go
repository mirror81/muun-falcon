package app_provided_data

// Config defines the global libwallet configuration.
type Config struct {
	DataDir                   string
	SocketPath                string
	FeatureStatusProvider     BackendActivatedFeatureStatusProvider
	AppLogSink                AppLogSink
	HttpClientSessionProvider HttpClientSessionProvider //nolint:staticcheck // TODO: struct field HttpClientSessionProvider should be HTTPClientSessionProvider
	NfcBridge                 NfcBridge
	KeyProvider               KeyProvider
	SecureKeyValueStorage     SecureKeyValueStorage
	Network                   string
}

package model

type SecurityCardsProviderJson struct {
	Name          string             `json:"name"`
	SecurityCards []SecurityCardJson `json:"securityCards"`
	CurrencyCode  string             `json:"currencyCode"`
}

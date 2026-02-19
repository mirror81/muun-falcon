package security_cards_marketplace

type Marketplace struct {
	Providers []SecurityCardsProvider
}

type SecurityCardsProvider struct {
	Name          string
	SecurityCards []SecurityCard
	CurrencyCode  string
}

type SecurityCard struct {
	Image string
}

package security_cards_marketplace

import (
	"github.com/muun/libwallet/domain/model/security_cards_marketplace"
	"github.com/muun/libwallet/service"
	"github.com/muun/libwallet/service/model"
)

type GetSecurityCardsMarketplaceAction struct {
}

func NewGetSecurityCardsMarketplaceAction() *GetSecurityCardsMarketplaceAction {
	return &GetSecurityCardsMarketplaceAction{}
}

func (ac *GetSecurityCardsMarketplaceAction) Run() (*security_cards_marketplace.Marketplace, error) {
	marketplaceJson := model.SecurityCardsMarketplaceJson{
		Providers: []model.SecurityCardsProviderJson{
			{
				Name: "Satochip",
				SecurityCards: []model.SecurityCardJson{
					{
						Image: "sc_satochip_1",
					},
					{
						Image: "sc_satochip_2",
					},
					{
						Image: "sc_satochip_3",
					},
				},
				CurrencyCode: "EUR",
			},
			{
				Name: "Coinkite",
				SecurityCards: []model.SecurityCardJson{
					{
						Image: "sc_coinkite_1",
					},
					{
						Image: "sc_coinkite_2",
					},
					{
						Image: "sc_coinkite_3",
					},
					{
						Image: "sc_coinkite_4",
					},
					{
						Image: "sc_coinkite_5",
					},
					{
						Image: "sc_coinkite_6",
					},
					{
						Image: "sc_coinkite_7",
					},
				},
				CurrencyCode: "USD",
			},
			{
				Name: "Onekey",
				SecurityCards: []model.SecurityCardJson{
					{
						Image: "sc_onekey_1",
					},
					{
						Image: "sc_onekey_2",
					},
					{
						Image: "sc_onekey_3",
					},
					{
						Image: "sc_onekey_4",
					},
					{
						Image: "sc_onekey_5",
					},
					{
						Image: "sc_onekey_6",
					},
				},
				CurrencyCode: "USD",
			},
		},
	}

	marketplace, err := service.MapSecurityCardsMarketplace(marketplaceJson)
	return marketplace, err
}

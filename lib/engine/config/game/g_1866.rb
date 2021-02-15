# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G1866
        JSON = <<-'DATA'
{
  "filename": "1866",
  "modulename": "1866",
  "currencyFormatStr": "%d₧",
  "bankCash": 7000,
  "certLimit": {
    "2": 20,
    "3": 14,
    "4": 11,
    "5": 10,
    "6": 9
  },
  "startingCash": {
    "2": 900,
    "3": 600,
    "4": 450,
    "5": 360,
    "6": 300
  },
"capitalization": "full",
  "layout": "flat",
  "mustSellInBlocks": true,
  "locationNames": {
    "C1": "Irun",
    "F2": "Andorra",
    "K3": "Perpignan",
    "G5": "Berga",
    "K5": "Figueras",
    "D6": "Balaguer",
    "I7": "Olot",
    "K7": "Girona",
    "E9": "Igualada",
    "G9": "Manrea",
    "B10": "Lleida",
    "J10": "Mataro",
    "A11": "Madrid",
    "H12": "Barcelona",
    "D14": "Reus",
    "E15": "Tarragona",
    "B16": "Tortosa",
    "A17": "Valencia",
    "H2": "Livia",
    "C17": "L'Ampolla"
  },
  "tiles": {
    "2": 1,
    "3": 1,
    "4": 1,
    "7": 7,
    "8": 7,
    "9": 7,
    "14": 2,
    "15": 2,
    "16": 2,
    "17": 1,
    "18": 1,
    "19": 2,
    "20": 2,
    "21": 1,
    "22": 1,
    "43": 1,
    "44": 1,
    "45": 2,
    "46": 2,
    "47": 1,
    "56": 1,
    "57": 5,
    "58": 1,
    "70": 1,
    "129": 1,
    "130": 1,
    "432": {
      "count": 1,
      "color": "brown",
      "code": "city=revenue:40;city=revenue:40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_1;path=a:4,b:_1;path=a:5,b:_1;path=a:_0,b:_1;label=C"
    },
    "448": 1,
    "449": 2,
    "450": 2,
    "627": 1,
    "628": 1,
    "630": 1,
    "632": 1,
    "633": 1
  },
  "market": [
    [
      "82",
      "90",
      "100",
      "112",
      "126",
      "142",
      "160",
      "180",
      "200",
      "225",
      "250",
      "275",
      "300",
      "325",
      "350"
    ],
    [
      "76",
      "82",
      "90",
      "100",
      "112",
      "126",
      "142",
      "165",
      "195",
      "225",
      "245",
      "265",
      "280",
      "295",
      "300"
    ],
    [
      "70",
      "76",
      "82",
      "90p",
      "100",
      "112",
      "126",
      "145",
      "175",
      "205",
      "225",
      "245",
      "260",
      "275",
      "290"
    ],
    [
      "65",
      "70",
      "76",
      "82",
      "90",
      "100",
      "115",
      "130",
      "160",
      "190",
      "210",
      "230"
    ],
    [
      "60",
      "66",
      "71",
      "76p",
      "82",
      "90",
      "100",
      "115",
      "140",
      "165"
    ],
    [
      "55",
      "62",
      "67",
      "71",
      "76",
      "82",
      "90",
      "100"
    ],
    [
      "50y",
      "58",
      "65",
      "67p",
      "71",
      "75",
      "80"
    ],
    [
      "45y",
      "54y",
      "63",
      "65",
      "69",
      "71"
    ],
    [
      "40o",
      "50y",
      "60y",
      "63",
      "68"
    ],
    [
      "30b",
      "40o",
      "50o",
      "60y"
    ],
    [
      "20b",
      "30b",
      "40o",
      "50y"
    ],
    [
      "10b",
      "20b",
      "30b",
      "40o"
    ]
  ],
  "companies": [
    {
      "name": "Companyia dels Camins de Ferro de Barcelona a Mataró",
      "value": 20,
      "revenue": 5,
      "desc": "Blocks I11 while owned by a player.",
      "sym": "FBM",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "I11"
          ]
        }
      ]
    },
    {
      "name": "Companyia dels Ferrocarrils de Tarragona a Barcelona i França",
      "value": 50,
      "revenue": 10,
      "desc": "Allows the owner of the private to open TBF. TBF may only be opened by the owner of this private. TBF can't be opened unless TMB and BFF are connected. If this private is sold to a Corporation TBF may no longer open.",
      "sym": "TBF",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["TBF"],
          "owner_type": "player",
          "from": "par"
        }
      ]
    },
    {
      "name": "Companyia dels Ferrocarrils de Tarragona a Barcelona i França",
      "value": 100,
      "revenue": 10,
      "desc": "When bought by a Corporation allows its lowest rank train to never rust. Train limit still applies.",
      "sym": "MTM",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "C4"
          ]
        }
      ]
    },
    {
      "name": "Companyia dels Ferrocarrils Directes de Madrid i Saragossa a Barcelona",
      "value": 140,
      "revenue": 0,
      "desc": "Only the Corporation owning this private may use the revenue from the offboard Madrid until the privates close. The owning Corporation may also upgrade 1 tile and subsquently place 1 token on a free space on that tile if available (no track conection needed and this upgrade is in addition to its normal OR actions)",
      "sym": "FMSB",
      "abilities": [
        {
          "type": "blocks_hexes",
          "hexes": [
            "A11"
          ]
        },
        {
          "type": "tile_lay",
          "owner_type":"corporation",
          "special": false,
          "hexes": [],
          "teleport": true,
          "tiles": [
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "43",
            "44",
            "45",
            "46",
            "47",
            "70",
            "129",
            "130",
            "432",
            "448",
            "449",
            "450",
            "627",
            "628"
          ],
          "when": ["special_track", "owning_corp_or_turn"],
          "count": 2
        }
      ]
    },
    {
      "name": "Miquel Biada",
      "value": 180,
      "revenue": 20,
      "desc": "This private comes with the 20% president's certificate of the Companyia del Ferrocarril de Saragossa a Barcelona (CFSB). The buying player must immediately set the par price for the CFSB to any par price. This private cannot be purchased by a Corporation and closes at the start of phase 5, or when the CFSB purchases a train.",
      "sym": "MB",
      "abilities": [
        {
          "type": "shares",
          "shares": "CFSB_0"
        },
       	{
					"type": "close",
					"when": "bought_train",
					"corporation": "CFSB"
				},

        {
          "type": "no_buy"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "BFF",
      "name": "BFF",
      "logo": "1866/BFF",
      "tokens": [
        0,
        40
      ],
      "coordinates": "K7",
      "color": "orange"
    },
    {
      "float_percent": 50,
      "sym": "LRT",
      "name": "LRT",
      "logo": "1866/LRT",
      "tokens": [
        0,
        40
      ],
      "coordinates": "D14",
      "color": "yellow"
    },
    {
      "float_percent": 50,
      "sym": "CFSB",
      "name": "CFSB",
      "logo": "1866/CFSB",
      "tokens": [
        0,
        40
      ],
      "coordinates": "B10",
      "color": "lightgray"
    },
    {
      "float_percent": 50,
      "sym": "CGFC",
      "name": "CGFC",
      "logo": "1866/CGFC",
      "tokens": [
        0,
        40
      ],
      "coordinates": "G5",
      "color": "blue"
    },
    {
      "float_percent": 50,
      "sym": "FSB",
      "name": "FSB",
      "logo": "1866/FSB",
      "tokens": [
        0,
        40,
        40
      ],
      "coordinates": "H12",
      "color": "gray"
    },
    {
      "float_percent": 50,
      "sym": "TMB",
      "name": "TMB",
      "logo": "1866/TMB",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E15",
      "color": "red"
    },
    {
      "float_percent": 50,
      "sym": "TBF",
      "name": "TBF",
      "logo": "1866/TBF",
      "tokens": [
        0,
        40,
        80
      ],
      "color": "black"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 100,
      "rusts_on": "4",
      "num": 5
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "5",
      "num": 5
    },
    {
      "name": "4",
      "distance": 4,
      "price": 340,
      "rusts_on": "6+",
      "num": 3
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "num": 2,
      "events":[
        {"type": "close_companies"}
      ]
    },
    {
      "name": "6+",
      "distance": [
        {
          "nodes":[
            "city",
            "offboard"
          ],
          "pay": 6,
          "visit": 6
        },
        {
          "nodes": [
            "town"
          ],
          "pay": 99,
          "visit": 99
        }
      ],
      "price": 660,
      "num": 2
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 10
    }
  ],
  "hexes": {
    "white": {
      "": [
        "H6",
        "L6",
        "C7",
        "G7",
        "F8",
        "H8",
        "C9",
        "K9",
        "F10",
        "H10",
        "I11",
        "F12",
        "G13",
        "F14"
      ],
      "upgrade=cost:40,terrain:mountain": [
        "D2",
        "E3",
        "H4",
        "J4",
        "I9"
      ],
      "city=revenue:0": [
        "K5",
        "K7",
        "G9",
        "J10"
      ],
      "city=revenue:40;upgrade=cost:40,terrain:mountain": [
        "G5",
        "D14"
      ],
      "town=revenue:0": [
        "L8"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "G3",
        "L4"
      ],
      "town=revenue:0;upgrade=cost:40,terrain:mountain;icon=image:1866/mine,sticky:1": [
        "I5"
      ],
      "town=revenue:0;town=revenue:0": [
        "D4",
        "E13"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "G11"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:1,type:water,cost:20": [
        "F4"
      ],
      "border=edge:2,type:water,cost:20": [
        "F6",
        "E11"
      ],
      "border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20": [
        "E7",
        "C13"
      ],
      "border=edge:2,type:water,cost:20;border=edge:3,type:water,cost:20": [
        "D12",
        "J8"
      ],
      "border=edge:0,type:water,cost:20": [
        "J6"
      ],
      "border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20": [
        "C15"
      ],
      "border=edge:3,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20": [
        "B12"
      ],
      "border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20": [
        "D8",
        "B14"
      ],
      "border=edge:0,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20": [
        "D10"
      ],
      "city=revenue:0;border=edge:1,type:water,cost:20;border=edge:2,type:water,cost:20": [
        "E9"
      ],
      "city=revenue:0;border=edge:5,type:water,cost:20": [
        "D6",
        "I7"
      ],
      "city=revenue:0;border=edge:0,type:water,cost:20": [
        "B10"
      ],
      "city=revenue:0;border=edge:4,type:water,cost:20": [
        "B16"
      ],
      "town=revenue:0;town=revenue:0;border=edge:0,type:water,cost:20;border=edge:1,type:water,cost:20;border=edge:5,type:water,cost:20": [
        "C11"
      ],
      "upgrade=cost:40,terrain:mountain;border=edge:0,type:water,cost:20;border=edge:4,type:water,cost:20;border=edge:5,type:water,cost:20": [
        "E5"
      ]
    },
    "yellow": {
      "city=revenue:30;city=revenue:30;path=a:2,b:_0;path=a:4,b:_1;label=C": [
        "H12"
      ]
    },
    "gray": {
      "city=revenue:40,slots:1;path=a:3,b:_0;path=a:4,b:_0": [
        "E15"
      ],
      "town=revenue:10;path=a:0,b:_0;path=a:_0,b:1": [
        "H2"
      ],
      "town=revenue:10;path=a:2,b:_0;path=a:_0,b:3": [
        "C17"
      ]
    },
    "red": {
      "offboard=revenue:yellow_30|brown_50;path=a:5,b:_0": [
        "C1"
      ],
      "offboard=revenue:yellow_20|brown_40,visit_cost:0;path=a:0,b:_0": [
        "F2"
      ],
      "offboard=revenue:yellow_30|brown_80;path=a:5,b:_0": [
        "K3"
      ],
      "offboard=revenue:yellow_30|brown_80;path=a:4,b:_0;path=a:5,b:_0": [
        "A11"
      ],
      "offboard=revenue:yellow_20|brown_40;path=a:4,b:_0": [
        "A17"
      ]
    },
    "blue": {
      "offboard=revenue:30;path=a:3,b:_0": [
        "H14"
      ],
      "offboard=revenue:30;path=a:2,b:_0": [
        "I13"
      ]
    }
  },
  "phases": [
    {
      "name": "2",
      "train_limit": 4,
      "tiles": [
        "yellow"
      ],
      "operating_rounds": 1
    },
    {
      "name": "3",
      "on": "3",
      "train_limit": 4,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "status":[
        "can_buy_companies"
      ]
    },
    {
      "name": "4",
      "on": "4",
      "train_limit": 3,
      "tiles": [
        "yellow",
        "green"
      ],
      "operating_rounds": 2,
      "status":[
        "can_buy_companies"
      ]
    },
    {
      "name": "5",
      "on": "5",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "6",
      "on": "6+",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    },
    {
      "name": "D",
      "on": "D",
      "train_limit": 2,
      "tiles": [
        "yellow",
        "green",
        "brown"
      ],
      "operating_rounds": 3
    }
  ]
}
        DATA
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

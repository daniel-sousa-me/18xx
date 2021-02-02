# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength, Layout/HeredocIndentation

module Engine
  module Config
    module Game
      module G18PC
        JSON = <<-'DATA'
{
  "filename": "18_pc",
  "modulename": "18PC",
  "currencyFormatStr": "%d₧",
  "bankCash": 7000,
  "certLimit": {
    "2": 25,
    "3": 19,
    "4": 14,
    "5": 12,
    "6": 11
  },
  "startingCash": {
    "2": 420,
    "3": 420,
    "4": 420,
    "5": 390,
    "6": 390
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
    "3": 2,
    "5": 2,
    "6": 2,
    "7": 2,
    "8": 5,
    "9": 5,
    "12": 1,
    "13": 1,
    "14": 1,
    "15": 3,
    "16": 1,
    "19": 1,
    "20": 1,
    "23": 2,
    "24": 2,
    "25": 1,
    "26": 1,
    "27": 1,
    "28": 1,
    "29": 1,
    "39": 1,
    "40": 1,
    "41": 1,
    "42": 1,
    "45": 1,
    "46": 1,
    "47": 1,
    "57": 2,
    "58": 3,
    "205": 1,
    "206": 1,
    "437": 1,
    "438": 1,
    "439": 1,
    "440": 1,
    "448": 4,
    "465": 1,
    "466": 1,
    "492": 1,
    "611": 2
  },
  "market": [
    [
      "55",
      "60",
      "65",
      "70",
      "75",
      "80p",
      "100",
      "110",
      "120",
      "130",
      "140",
      "150",
      "160",
      "170",
      "180",
      "200"
    ],
    [
      "50",
      "55",
      "60",
      "65",
      "70p",
      "75",
      "80",
      "100",
      "110",
      "120",
      "130",
      "140",
      "150",
      "160",
      "170",
      "180"
    ],
    [
      "40y",
      "50",
      "55",
      "60p",
      "65",
      "70",
      "75",
      "80",
      "90",
      "100",
      "110",
      "120",
      "130",
      "140",
      "150"
    ],
    [
      "30b",
      "40y",
      "50",
      "55",
      "60",
      "65",
      "70",
      "75",
      "80",
      "90",
      "100",
      "110",
      "120"
    ],
    [
      "20b",
      "30y",
      "40y",
      "50",
      "55",
      "60",
      "65",
      "70",
      "75",
      "80"
    ],
    [
      "10b",
      "20b",
      "30y",
      "40y",
      "50y",
      "55y"
    ],
    [
      "0c",
      "10b",
      "20b",
      "30b",
      "40b",
      "50b"
    ]
  ],
  "companies": [
    {
      "name": "FBM",
      "value": 20,
      "revenue": 5,
      "desc": "I11 while owned by a player.",
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
      "name": "Mitsubishi Ferry",
      "value": 30,
      "revenue": 5,
      "desc": "Player owner may place the port tile on a coastal town (B11, G10, I12, or J9) without a tile on it already, outside of the operating rounds of a corporation controlled by another player. The player need not control a corporation or have connectivity to the placed tile from one of their corporations. This does not close the company.",
      "sym": "MF",
      "abilities": [
        {
          "type": "tile_lay",
          "when": "any",
          "hexes": [
            "B11",
            "G10",
            "I12",
            "J9"
          ],
          "tiles": [
            "437"
          ],
          "owner_type": "player",
          "count": 1
        }
      ]
    },
    {
      "name": "Ehime Railway",
      "value": 40,
      "revenue": 10,
      "desc": "When this company is sold to a corporation, the selling player may immediately place a green tile on Ohzu (C4), in addition to any tile which it may lay during the same operating round. This does not close the company. Blocks C4 while owned by a player.",
      "sym": "ER",
      "abilities": [
        {
          "type": "blocks_hexes",
          "owner_type": "player",
          "hexes": [
            "C4"
          ]
        },
        {
          "type": "tile_lay",
          "hexes": [
            "C4"
          ],
          "tiles": [
            "12",
            "13",
            "14",
            "15",
            "205",
            "206"
          ],
          "when": "sold",
          "owner_type": "corporation",
          "count": 1
        }
      ]
    },
    {
      "name": "Sumitomo Mines Railway",
      "value": 50,
      "revenue": 15,
      "desc": "Owning corporation may ignore building cost for mountain hexes which do not also contain rivers. This does not close the company.",
      "sym": "SMR",
      "abilities": [
        {
          "type": "tile_discount",
          "discount" : 80,
          "terrain": "mountain",
          "owner_type": "corporation"
        }
      ]
    },
    {
      "name": "Dougo Railway",
      "value": 60,
      "revenue": 15,
      "desc": "Owning player may exchange this private company for a 10% share of Iyo Railway from the initial offering.",
      "sym": "DR",
      "abilities": [
        {
          "type": "exchange",
          "corporations": ["IR"],
          "owner_type": "player",
          "when": "any",
          "from": "ipo"
        }
      ]
    },
    {
      "name": "South Iyo Railway",
      "value": 80,
      "revenue": 20,
      "desc": "No special abilities.",
      "sym": "SIR",
      "min_players": 3
    },
    {
      "name": "Uno-Takamatsu Ferry",
      "value": 150,
      "revenue": 30,
      "desc": "Does not close while owned by a player. If owned by a player when the first 5-train is purchased it may no longer be sold to a public company and the revenue is increased to 50.",
      "sym": "UTF",
      "min_players": 4,
      "abilities": [
        {
          "type": "close",
          "on_phase": "never",
          "owner_type": "player"
        },
        {
          "type": "revenue_change",
          "revenue": 50,
          "on_phase": "5",
          "owner_type": "player"
        }
      ]
    }
  ],
  "corporations": [
    {
      "float_percent": 50,
      "sym": "BFF",
      "name": "BFF",
      "logo": "18PC/BFF",
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
      "logo": "18PC/LRT",
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
      "logo": "18PC/CFSB",
      "tokens": [
        0,
        40
      ],
      "coordinates": "B10",
      "color": "white"
    },
    {
      "float_percent": 50,
      "sym": "CGFC",
      "name": "CGFC",
      "logo": "18PC/KO",
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
      "logo": "18PC/FSB",
      "tokens": [
        0,
        40,
        40
      ],
			"city": 2,
      "coordinates": "H12",
      "color": "gray"
    },
    {
      "float_percent": 50,
      "sym": "TMB",
      "name": "TMB",
      "logo": "18PC/TMB",
      "tokens": [
        0,
        40
      ],
      "coordinates": "E15",
      "color": "red"
    }
  ],
  "trains": [
    {
      "name": "2",
      "distance": 2,
      "price": 80,
      "rusts_on": "4",
      "num": 6
    },
    {
      "name": "3",
      "distance": 3,
      "price": 180,
      "rusts_on": "6",
      "num": 5
    },
    {
      "name": "4",
      "distance": 4,
      "price": 300,
      "rusts_on": "D",
      "num": 4
    },
    {
      "name": "5",
      "distance": 5,
      "price": 450,
      "num": 3,
      "events":[
        {"type": "close_companies"}
      ]
    },
    {
      "name": "6",
      "distance": 6,
      "price": 630,
      "num": 2
    },
    {
      "name": "D",
      "distance": 999,
      "price": 1100,
      "num": 20,
      "available_on": "6",
      "discount": {
        "4": 300,
        "5": 300,
        "6": 300
      }
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
        "L4",
        "I5"
      ],
      "town=revenue:0;town=revenue:0": [
        "D4",
        "E13"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain": [
        "G11"
      ],
      "town=revenue:0;town=revenue:0;upgrade=cost:40,terrain:mountain;border=edge:1": [
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
      "city=revenue:30,loc:1.5;city=revenue:30,loc:4.5;city=revenue:30,loc:3;path=a:2,b:_0;path=a:4,b:_1": [
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
      "offboard=revenue:yellow_20|brown_40;path=a:0,b:_0": [
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
      "on": "6",
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

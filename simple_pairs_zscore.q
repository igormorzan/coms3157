/ Simple Z-Score Based Pairs Formation
/ kdb/q implementation

/ Calculate z-score
zscore:{[x] (x - avg x) % dev x}

/ Calculate Barra-style factors for each stock
calcFactors:{[prices; volumes]
  / prices: table with columns (date; sym; price)
  / volumes: table with columns (date; sym; volume)
  
  / Join prices and volumes
  data: prices lj volumes;
  
  / Calculate factors by symbol
  factors: select 
    / Momentum: 12M return excluding last month
    momentum: (last price % first price) - (last price % price[count[price]-22]),
    / Size: log of last price (proxy for market cap)
    size: log last price,
    / Value: inverse of price change
    value: neg (last price % first price) - 1,
    / Volatility: std dev of returns
    volatility: dev 1_ price % prev price,
    / Liquidity: average volume
    liquidity: avg volume,
    / Growth: acceleration of returns
    growth: avg 1_ deltas 1_ price % prev price
  by sym from data;
  
  / Standardize all factors (z-score)
  update 
    momentum: zscore momentum,
    size: zscore size,
    value: zscore value,
    volatility: zscore volatility,
    liquidity: zscore liquidity,
    growth: zscore growth
  from factors
  }

/ Calculate Euclidean distance between two vectors
euclideanDist:{[v1; v2]
  sqrt sum (v1 - v2) xexp 2
  }

/ Find pairs based on factor similarity
findPairs:{[factors; n]
  / factors: table from calcFactors
  / n: number of top pairs to return
  
  / Get list of symbols
  syms: exec sym from factors;
  numSyms: count syms;
  
  / Get factor columns
  factorCols: `momentum`size`value`volatility`liquidity`growth;
  
  / Create pairs table
  pairs: ([] sym1:`symbol$(); sym2:`symbol$(); distance:`float$());
  
  / Calculate all pairwise distances
  i: 0;
  while[i < numSyms - 1;
    / Get factors for symbol i
    row1: factors[i];
    f1: row1 factorCols;
    
    j: i + 1;
    while[j < numSyms;
      / Get factors for symbol j
      row2: factors[j];
      f2: row2 factorCols;
      
      / Calculate Euclidean distance in factor space
      dist: euclideanDist[f1; f2];
      
      / Add to pairs table
      pairs,: enlist `sym1`sym2`distance!(syms[i]; syms[j]; dist);
      
      j+: 1
    ];
    i+: 1
  ];
  
  / Sort by distance and return top n
  n sublist `distance xasc pairs
  }

/ EXAMPLE USAGE:

/ Your input data should look like:
/ prices: ([]
/   date: 2023.01.03 2023.01.03 2023.01.04 2023.01.04;
/   sym: `AAPL`MSFT`AAPL`MSFT;
/   price: 125.5 245.2 126.3 246.8
/ )
/
/ volumes: ([]
/   date: 2023.01.03 2023.01.03 2023.01.04 2023.01.04;
/   sym: `AAPL`MSFT`AAPL`MSFT;
/   volume: 50000000 25000000 48000000 26000000
/ )

/ Step 1: Calculate and z-score factors
/ factors: calcFactors[prices; volumes]

/ Step 2: Find top 20 pairs
/ pairs: findPairs[factors; 20]

/ Step 3: View results
/ show pairs

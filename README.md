# Alphacado

## Action Id

-   `1`: UniV2Adapter

## Deployed Address

### Mumbai

-   `Alphacado`: 0x147d1Ea2f6Fb25322c3bC91c3D1cFfebc4A55576
-   `Registry`: 0x34907cDDbDFFb0a827FD5cd616e7B43667E56f8C

Adapters:

-   `UniV2Adapters`: 0x75055303e8ACa5F966AA15BacAE9172A5887C534

### BNB Testnet

-   `Alphacado`: 0x1972308BC7b0fb4e7CF49Ebef14207b07698a2C1
-   `Registry`: 0x6025b9d66D7d86cd9acD2c80318E447b8cA30A68

Adapters:

-   `UniV2Adapters`: 0x9cdF95B18e892820ff61147DD20fA93AA763eDCC

## Simple Working case

Send `fromUniV2` on UniV2Adapters on Mumbai testnet with these following params:

-   msg.value: 0.018 ether
-   router: 0x8954afa98594b838bda56fe4c12a09d7739d179b (UniV2 router)
-   tokenB: 0x87A35f50E570F909F275F5C8AEC40FbeB9e76D17 (any address must work now)
-   liquidity: 10^18 = 1 ether (any amount must work now)
-   minimumSendAmount: 10^18 = 1 ether (any amount must work now)
-   target chain: 4 (BNB Testnet)
-   target chain action Id: 1 (UniV2Adapter)
-   receipient: your address
-   payload: abi encode of (targetChainRouter, targetChainTokenB, targetChainMinimumReceiveLiquidity) (you can use the gen_payload.ts file)

    ![Alt text](public/image.png)

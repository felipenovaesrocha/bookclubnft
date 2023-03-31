import "dotenv/config";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

// import "@nomiclabs/hardhat-etherscan";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    // gnosis: {
    //   url: "https://rpc.gnosischain.com",
    //   chainId: 100,
    //   accounts: [process.env.PK!],
    // },
  },
  typechain: {
    alwaysGenerateOverloads: true,
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      gnosis: process.env.GNOSISSCAN_API_KEY!,
    },
  },
};

export default config;

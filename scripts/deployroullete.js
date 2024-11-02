const { ethers } = require("hardhat");
const path = require("path");
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying RouletteGame contract with the account:", deployer.address);

  // Replace this with the actual MoneyPool contract address after deployment
  const moneyPoolAddress = "0x92F8B51e8141262137F18F2723728DF7a9165529"; // Update with MoneyPool's deployed address

  const RouletteGame = await ethers.getContractFactory("RouletteGame");
  const rouletteGame = await RouletteGame.deploy(moneyPoolAddress);
  await rouletteGame.waitForDeployment();

  console.log("RouletteGame deployed to:", await rouletteGame.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

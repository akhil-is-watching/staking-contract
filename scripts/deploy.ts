import { ethers } from "hardhat";

async function main() {
  const DEFI = await ethers.deployContract("DEFI", []);
  await DEFI.waitForDeployment();
  const Staking = await ethers.deployContract("Staking", [DEFI.target])
  await Staking.waitForDeployment();

  console.log(
    `
      DEFI: ${DEFI.target}
      Staking: ${Staking.target}
    `
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

const FileHashVerification = artifacts.require("FileHashVerification");
const fs = require("fs");
const path = require("path");

module.exports = async function (deployer) {
  await deployer.deploy(FileHashVerification);

  const instance = await FileHashVerification.deployed();
  const frontendConfig = path.join(__dirname, "..", "frontend", "contract-config.js");
  fs.writeFileSync(
    frontendConfig,
    `window.VERITY_CONTRACT_ADDRESS = "${instance.address}";\n`,
    "utf8"
  );
  console.log(`Updated frontend contract address: ${instance.address}`);
};

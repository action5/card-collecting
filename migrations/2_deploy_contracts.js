var storage = artifacts.require("ApplicationStorage");
var controller = artifacts.require("ApplicationController");
var proxy = artifacts.require("CardCollecting");

module.exports = async (deployer) => {
    let cardsTotalSupply = 1000000;
    await deployer.deploy(storage, cardsTotalSupply);
    await deployer.deploy(controller, storage.address);
    await deployer.deploy(proxy, controller.address);
};

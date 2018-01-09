pragma solidity ^0.4.17;

import "../utility/Mortal.sol";
import "../controller/IApplicationController.sol";

contract CardCollecting is Mortal {

	event ControllerUpdate(address oldAddress, address newAddress);

	IApplicationController public controller;

	function CardCollecting(address controllerAddress) {
		controller = IApplicationController(controllerAddress);
	}

	function updateController(address newControllerAddress) onlyAuthorized external {
		controller.transferStorage(newControllerAddress);
		address oldControllerAddress = address(controller);
		controller = IApplicationController(newControllerAddress);
		ControllerUpdate(oldControllerAddress, newControllerAddress);
	}

}

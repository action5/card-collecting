pragma solidity ^0.4.17;

import "./IApplicationController.sol";
import "../utility/Mortal.sol";
import "../utility/Escrow.sol";
import "../storage/ApplicationStorage.sol";

contract ApplicationController is Mortal, IApplicationController {

	event CardCreation(uint32 cardIndex, address receiver);
	event EscrowCreation(uint32 cardIndex, address seller, address buyer, uint price);
	event Withdrawal(address owner, address receiver, uint amount);
	event StorageTransfer(address from, address to);

	ApplicationStorage public applicationStorage;

	function ApplicationController(address storageAddress) {
		applicationStorage = ApplicationStorage(storageAddress);
	}

	function getCard(uint8 cardShape, uint8 cardColor, uint8 cardSign, address receiver) external {
		uint32 cardsQuantity = applicationStorage.getCardsQuantity();
		uint32 cardsTotalSupply = applicationStorage.cardsTotalSupply();
		require(cardsQuantity < cardsTotalSupply);

		uint32 cardIndex = applicationStorage.createCard(cardShape, cardColor, cardSign, receiver);
		CardCreation(cardIndex, receiver);
	}

	// to create escrow where buyer is unknown at the moment,
	// pass 0x0 as function 'buyer' argument
	function createEscrow(uint32 cardIndex, address buyer, uint price) external {
		address seller = applicationStorage.cardOwners(cardIndex);
		uint32 cardCurrentMaxIndex = applicationStorage.getCardsQuantity() - 1;
		require(cardIndex <= cardCurrentMaxIndex);
		if (buyer != 0x0){
			require(buyer != seller);
			require(buyer.balance >= price);
		}

		Escrow escrow = new Escrow(cardIndex, seller, buyer, price, applicationStorage);
		applicationStorage.addEscrow(escrow);
		EscrowCreation(cardIndex, seller, buyer, price);
	}

	function withdraw(address receiver) external {
		uint amount = applicationStorage.pendingWithdrawals(msg.sender);
		require(amount > 0);

		applicationStorage.setWithdrawal(msg.sender, 0);
		receiver.transfer(amount);
		Withdrawal(msg.sender, receiver, amount);
	}

	function transferStorage(address to) external {
		require(accessAllowed[msg.sender] == true);
		applicationStorage.transferLocation(to);
		StorageTransfer(this, to);
	}

}

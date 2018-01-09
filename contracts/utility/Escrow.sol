pragma solidity ^0.4.17;

import "../storage/ApplicationStorage.sol";

contract Escrow {

	event EscrowCompletion(uint32 cardIndex, address seller, address buyer, uint price);
	event EscrowCancellation(uint32 cardIndex, address seller, address buyer, uint price);

	enum EscrowStatus { Unactive, Pending, Agreed, Completed, Canceled }

	uint32 public cardIndex;
	address public seller;
	address public buyer;
	uint public price;

	bool public sellerApprove;
	bool public buyerApprove;

	uint public escrowFee;
	EscrowStatus public escrowStatus;

	ApplicationStorage public applicationStorage;

	modifier onlyBuyer {
		require (msg.sender == buyer);
		_;
	}

	modifier onlyParticipant {
		require (msg.sender == seller || msg.sender == buyer);
		_;
	}

	modifier atStage(EscrowStatus _escrowStatus) {
		require(escrowStatus == _escrowStatus);
		_;
	}

	function Escrow(uint32 _cardIndex, address _seller, address _buyer,
						uint _price, address applicationStorageAddress) {

		cardIndex = _cardIndex;
		seller = _seller;
		buyer = _buyer;
		price = _price;
		escrowFee = price / 20; // 5%

		if(buyer == 0x0) {
			escrowStatus = EscrowStatus.Unactive;
		} else {
			escrowStatus = EscrowStatus.Pending;
		}

		applicationStorage = ApplicationStorage(applicationStorageAddress);
	}

	function becomeBuyer() external atStage(EscrowStatus.Unactive) {
		address _buyer = msg.sender;
		require(_buyer != seller);
		require(_buyer.balance >= price);
		buyer = _buyer;
		escrowStatus = EscrowStatus.Pending;
	}

	function approve() external atStage(EscrowStatus.Pending) onlyParticipant {
		if(msg.sender == buyer) buyerApprove = true;
		else if(msg.sender == seller) sellerApprove = true;

		if(sellerApprove && buyerApprove) escrowStatus = EscrowStatus.Agreed;
	}

	function disApprove() external atStage(EscrowStatus.Pending) onlyParticipant {
		if(msg.sender == buyer) buyerApprove = false;
		else if (msg.sender == seller) sellerApprove = false;
	}

	function payOut() external payable atStage(EscrowStatus.Agreed) onlyBuyer {
		// double-check whether seller is still owner of card
		if(applicationStorage.cardOwners(cardIndex) != seller){
			revert();
			escrowStatus = EscrowStatus.Canceled;
		}
		require(msg.value >= price + escrowFee);

		applicationStorage.transfer(msg.value);

		uint currentSellerWithdrawal = applicationStorage.pendingWithdrawals(seller);
		uint updatedSellerWithdrawal = currentSellerWithdrawal + price;
		applicationStorage.setWithdrawal(seller, updatedSellerWithdrawal);

		uint currentStorageWithdrawal = applicationStorage.pendingWithdrawals(applicationStorage);
		uint updatedStorageWithdrawal = currentStorageWithdrawal + (msg.value - price);
		applicationStorage.setWithdrawal(applicationStorage, updatedStorageWithdrawal);

		applicationStorage.setCardOwner(cardIndex, buyer);

		escrowStatus = EscrowStatus.Completed;
		EscrowCompletion(cardIndex, seller, buyer, price);
	}

	function cancel() external atStage(EscrowStatus.Pending) onlyParticipant {
		escrowStatus = EscrowStatus.Canceled;
		EscrowCancellation(cardIndex, seller, buyer, price);
	}

}

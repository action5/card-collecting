pragma solidity ^0.4.17;

import "../utility/Ownable.sol";
import "../utility/CardInfo.sol";
import "../utility/Escrow.sol";

contract ApplicationStorage is Ownable {

	uint32 public cardsTotalSupply;

	CardInfo.Card[] public cards;
	Escrow[] public escrows;

	// card index to owner address
	mapping (uint32 => address) public cardOwners;

	// receiver address to withdrawal amount
	mapping (address => uint) public pendingWithdrawals;

	function ApplicationStorage(uint32 _cardsTotalSupply) {
		cardsTotalSupply = _cardsTotalSupply;
	}

	function createCard(uint8 _shape, uint8 _color, uint8 _sign, address receiver)
	                                        onlyAuthorized external returns (uint32) {

		cards.push(CardInfo.Card({
			shape: CardInfo.Shape(_shape),
			color: CardInfo.Color(_color),
			sign: CardInfo.Sign(_sign)
		}));
		uint32 cardIndex = uint32(cards.length) - 1;
		cardOwners[cardIndex] = receiver;
		return cardIndex;
	}

	function addEscrow(Escrow escrow) external onlyAuthorized {
		escrows.push(escrow);
		accessAllowed[escrow] == true;
	}

	function transferLocation(address to) external onlyAuthorized {
		accessAllowed[msg.sender] == false;
		accessAllowed[to] == true;
	}

	function getCardsQuantity() external view returns (uint32) {
		return uint32(cards.length);
	}

	function setCardOwner(uint32 cardIndex, address newOwner) external onlyAuthorized {
		cardOwners[cardIndex] = newOwner;
	}

	function setWithdrawal(address receiver, uint amount) external onlyAuthorized {
		pendingWithdrawals[receiver] = amount;
	}

	function () external payable {
		pendingWithdrawals[this] += msg.value;
	}

}

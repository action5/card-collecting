pragma solidity ^0.4.17;

import "./Ownable.sol";

contract Mortal is Ownable {

	event Kill(address contractAddress);

	function kill() external onlyOwner {
		Kill(this);
		selfdestruct(owner);
	}

}

pragma solidity ^0.4.17;

contract Ownable {

	event AccessAllowed(address to);
	event AccessDenied(address to);
	event OwnershipTransfer(address oldOwner, address newOwner);

	address public owner;
	mapping(address => bool) public accessAllowed;

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	modifier onlyAuthorized {
		require(accessAllowed[msg.sender] == true);
		_;
	}

	function Ownable() public {
		owner = msg.sender;
		accessAllowed[msg.sender] = true;
	}

	function allowAccess(address to) public onlyOwner {
		accessAllowed[to] = true;
		AccessAllowed(to);
	}

	function denyAccess(address to) public onlyOwner {
		accessAllowed[to] = false;
		AccessDenied(to);
	}

	function transferOwnership(address newOwner) public onlyOwner {
		address oldOwner = owner;
		owner = newOwner;
		accessAllowed[newOwner] = true;
		OwnershipTransfer(oldOwner, newOwner);
	}
}

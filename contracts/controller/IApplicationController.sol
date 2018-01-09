pragma solidity ^0.4.17;

interface IApplicationController {

	function getCard(uint8 cardShape, uint8 cardColor, uint8 cardSign, address receiver) external;

	function createEscrow(uint32 cardIndex, address buyer, uint price) external;

	function withdraw(address receiver) external;

	function transferStorage(address to) external;

}

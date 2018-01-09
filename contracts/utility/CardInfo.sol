pragma solidity ^0.4.17;

library CardInfo {

	enum Shape { Rectangular, Oval, Diamond }
	enum Color { Red, Green, Blue, Yellow, Black, White }
	enum Sign {	Star, Circle, Square, Point, Cross }

	struct Card {
		Shape shape;
		Color color;
		Sign sign;
	}

}

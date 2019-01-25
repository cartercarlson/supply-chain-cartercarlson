pragma solidity ^0.4.23;

contract SupplyChain {

	/* VARIABLE DECLARATION */
	address public owner;
	int public skuCount;

	/* MAPPING */
	mapping(uint => Item) public items;

	/* ENUM	*/
	enum State { ForSale, Sold, Shipped, Received }

	/* STRUCTS */
	struct Item {
		string name;
		uint sku;
		uint price;
		uint state;
		address seller;
		address buyer;
	}

	/* EVENTS */
	event ForSale (uint sku);
	event Sold (uint sku);
	event Shipped (uint sku);
	event Received (uint sku);

	/* MODIFIERS */
	modifier forSale(uint _sku) { require(items[_sku].state == 'ForSale'); _; }
	modifier sold(uint _sku) { require(items[_sku].state == 'Sold'); _; }
	modifier shipped(uint _sku) { require(items[_sku].state == 'Shipped'); _; }
	modifier received(uint _sku) { require(items[_sku].state == 'Received'); _; }
	modifier verifyCaller(address _address) { require (msg.sender == _address); _;}
	modifier paidEnough(uint _price) { require(msg.value >= _price); _;}
	modifier checkValue(uint _sku) {
		_;
		uint _price = items[_sku].price;
		uint amountToRefund = msg.value - _price;
		items[_sku].buyer.transfer(amountToRefund);
	}
	
	/* CONSTRUCTOR */
	constructor() public {
		owner = msg.sender;
		skuCount = 0;
	}

	/* FUNCTIONS */
	function addItem(string _name, uint _price)
		public
		returns(bool)
	{
		emit ForSale(skuCount);
		items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
		skuCount = skuCount + 1;
		return true;
	}

	function buyItem(uint _sku)
		public
		payable
	{
		emit Sold(_sku);
		forSale(_sku);
		paidEnough(items[_sku].price);
		checkValue(_sku);
		items[_sku].buyer = msg.sender;
		items[_sku].state = 'Sold';
	}

	function shipItem(string _name, uint _sku)
		public
	{
		emit Shipped(_sku);
		verifyCaller(msg.sender);
		sold(_sku);
	}

	function receiveItem(uint _sku)
		public
	{
		emit Received(_sku);
		shipped(_sku);
		received(_sku);
		items[_sku].state = 'Received';
	}

}

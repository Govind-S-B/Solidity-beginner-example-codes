pragma solidity ^0.8.0;

contract Escrow {
    address payable public buyer;
    address payable public seller;
    address public arbitrator;
    uint public amount;
    bool public buyerConfirmed;
    bool public sellerConfirmed;

    constructor(address payable _buyer, address payable _seller, address _arbitrator) payable {
        buyer = _buyer;
        seller = _seller;
        arbitrator = _arbitrator;
        amount = msg.value;
    }

    function confirmReceipt() public {
        require(msg.sender == buyer);
        require(!buyerConfirmed);
        buyerConfirmed = true;
        if (sellerConfirmed) {
            releaseFunds();
        }
    }

    function confirmDelivery() public {
        require(msg.sender == seller);
        require(!sellerConfirmed);
        sellerConfirmed = true;
        if (buyerConfirmed) {
            releaseFunds();
        }
    }

    function releaseFunds() private {
        if (arbitrator != address(0)) {
            arbitrator.transfer(amount);
        } else {
            seller.transfer(amount);
        }
    }

    function refund() public {
        require(msg.sender == arbitrator);
        require(!buyerConfirmed || !sellerConfirmed);
        if (buyerConfirmed && !sellerConfirmed) {
            buyer.transfer(amount);
        } else if (!buyerConfirmed && sellerConfirmed) {
            seller.transfer(amount);
        } else {
            // Both parties must confirm receipt or delivery before a refund can be issued.
            revert();
        }
    }
}
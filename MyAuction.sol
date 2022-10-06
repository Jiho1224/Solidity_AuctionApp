pragma solidity ^0.8.17; //version 선언

import "./Auction.sol";

//Abstract class인 auction을 상속하는 myauction class
contract MyAuction is Auction {

    //constructor => 계약이 처음 블록체인에 배치될 때 한 번만 실행됨
    constructor (uint _biddingTime, address _owner, string memory _goods_name,
    string memory _start_bid, string memory _Rnumber) public {
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime * 1 hours;
        STATE = auction_state.STARTED;
        MyGoods.goods_name = _goods_name;
        MyGoods.start_bid = _start_bid;
        MyGoods.Rnumber = _Rnumber;
    }

  
    // 호가 함수 bid
    // an_ongoing_auction => 경매가 진행 중일 때에만 실행될 수 있도록
    function bid() public payable an_ongoing_auction override returns (bool) {
        
        require(bids[msg.sender] + msg.value > highestBid, "Cannot Bid"); // 호가가 성공적으로 이루어졌는지 확인
        highestBidder = msg.sender; //가장 높은 가격을 호가한 사람을 msg.sender로 재설정
        highestBid = msg.value; // 현재 호가를 가장 높은 가격으로 지정
        bidders.push(msg.sender); //bidder 배열에 추가
        bids[msg.sender] = bids[msg.sender] + msg.value; //응찰자의 주소를 참가자의 주소 배열에 추가
        emit BidEvent(highestBidder, highestBid); //event 발생시켜서 최고가와 응찰자를 프론트에 전달
        return true; // 성공적으로 호가가 완료되었으므로 true 반환
    
    }

    // 경매 취소 함수 cancel_auction
    // 경매 소유자만 호출할 수 있어야 함
    function cancel_auction() only_owner an_ongoing_auction  external override returns (bool){
        STATE = auction_state.CANCELLED; //경매 상태를 cancel로 바꿈
        CanceledEvent("Complete. Auction Cancelled",block.timestamp); // event를 호출하여 경매가 취소되었음을 알려줌
        return true;
    }

    // 매수 신청액을 회수하는 함수 withdraw
    // 경매 종료 이후 낙찰자 이외의 참가자들이 자신의 매수 신청액을 다시 가져가도록

    function withdraw() public override returns (bool){
        require(block.timestamp > auction_end, "Cannot withdraw. Auction is still opened");

        uint amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        withdrawalEvent(msg.sender,amount);
        return true;
    }

    // 계약을 파괴하는 함수 destruct_auction

    function destruct_auction() external only_owner returns(bool) {
        require (block.timestamp > auction_end, "Failed. Auction is still opened");

        for(uint i = 0; i<bidders.length; i++){
            assert(bids[bidders[i]] == 0);
        }

        selfdestruct(payable(auction_owner));
        return true;
    }


}
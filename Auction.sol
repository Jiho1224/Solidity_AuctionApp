pragma solidity ^0.8.17; //version 선언

contract Auction {
    address internal auction_owner; //원 소유자
    uint256 public auction_start; //계약 배치 시 경매 시작
    uint256 public auction_end; //호가 기간 종료 시 경매 종료
    uint256 public highestBid; //가장 높은 가격
    address public highestBidder; //가장 높은 가격을 호가한 사람

    //경매의 상태를 저장한 ENUM
    enum auction_state{
        CANCELLED,STARTED
    }

    struct goods{
        string goods_name; //상품이름
        string start_bid; //시작가
        string Rnumber; //상품등록번호
    }

    goods public MyGoods;
    address[] bidders; //경매 참가자들의 배열
    mapping(address => uint) public bids; //각 매수 신청자의 주소를 매수 신청액에 mapping
    auction_state public STATE;

    //현재 경매 진행 중인지 파악하기 위한 modifier(사용자 정의 함수 제한자)
    modifier an_ongoing_auction(){
        require(block.timestamp <= auction_end); //경매 종료 시간 보다 작아야 동작!
        _;
    }

    //함수 호출자가 계약 소유자인지 확인하는 함수 제한자
    modifier only_owner() {
        require(msg.sender == auction_owner); 
        _;
    }

    //abstract functions
    function bid() public payable returns(bool){}
    function withdraw() public returns(bool){}
    function cancel_auction() external returns (bool){}

    //events
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event withdrawalEvent(address withdrawer,uint256 amount);
    event CanceledEvent(string message, uint256 time);
}




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

    //참가자가 매수 신청액을 지정하는 함수.
    //경매의 호가 => 누적 방식
    function bid() public payable returns(bool){}

    //경매 종료 후, 참가자가 자신의 매수 신청액을 회수하는 함수
    function withdraw() public returns(bool){}

    // 경매 소유자가 자신이 시작한 경매를 취소하는 함수
    function cancel_auction() external returns (bool){}

    //event 
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event withdrawalEvent(address withdrawer,uint256 amount);
    event CanceledEvent(string message, uint256 time);
}

//About Function
// constant, view: 함수가 계약의 상태를 변경하지 못할 경우
// pure : 함수가 계약에 저장된 상태를 변경하기는 커녕 읽지도 않을 경우
// payable : 함수가 이더를 받을 수 있음

//조건, 오류 처리

// assert : 조건이 충족하지 않는 경우 예외를 발생시킴. 예외 발생 시 남은 모든 가스가
//          소비되며 모든 변경 사항이 철회 (계약 내부에서 발생한 오류)
//    사용 => 계약에 해가 되는 연산을 방지할 때 사용
//require : 조건이 충족하지 않는 경우 예외를 발생. 예외 발생 시 남은 모든
//           가스가 호출자에게 환급
//    사용 => 유효한 조건을 보장하는데에 사용
// revert : 실행을 중지하고 상태 변경을 철회. 가스를 환급
// throw : 예외를 발생시키고, 남은 모든 가스를 소비





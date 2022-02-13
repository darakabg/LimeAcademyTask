pragma solidity ^0.8.0;
pragma abicoder v2;
import "./Ownable.sol";

contract BookLibrary is Ownable {
    struct Book{
        string title;
        uint copies;
    }

    mapping(uint => address[]) public bookToBorrowers;
    mapping(address => uint[]) public userToCurrentBorrows;

    modifier containsBook(string memory _title, Book[] memory _library) {
        bool _contains;

        for(uint i = 0; i < _library.length; i++){
            if(keccak256(abi.encodePacked(_library[i].title)) == keccak256(abi.encodePacked((_title)))){
                _contains = true;
            } else{
                _contains = false;
            }
        }
        require(!_contains, "The library contains that book!");
        _;
    } 

    modifier hasCopies(uint _copies){
        require(_copies > 0, "This book must have at least 1 copy!");
        _;
    }

    modifier borrowed(address _user, uint _bookId){
        bool _isBorrowed;
        uint[] memory _userBooks = userToCurrentBorrows[_user];
        for(uint i = 0; i < _userBooks.length; i++){
            if(_userBooks[i] == _bookId){
                _isBorrowed = true;
            } else{
                _isBorrowed = false;
            }
        }    
        require(!_isBorrowed, "The user has aready borrowed a copy!");
        _;
    }

    modifier hasBook(address _user, uint _bookId){
        bool _isBorrowed;
        uint[] memory _userBooks = userToCurrentBorrows[_user];
        for (uint i = 0; i < _userBooks.length; i++){
            if(_bookId == _userBooks[i]){
                _isBorrowed = true;
            } else{
                _isBorrowed = false;
            }
        }
        require(_isBorrowed, "The user didn't borrow a copy of this book!");
        _;
    }

    modifier libraryContains(uint _bookId, Book[] memory _library){
        require(_bookId < _library.length && _bookId >= 0, "Book with this ID doesn't exist in the library.");
        _;
    }

    Book[] public books;

    function addBook(string calldata _title, uint _copies) external onlyOwner containsBook(_title, books) hasCopies(_copies){
        books.push(Book(_title, _copies));
        uint _bookId = books.length - 1;
        bookToBorrowers[_bookId];         
    }

    function viewAll() external view returns(string memory) {
        require(books.length > 0, "There are no availale books in the library!");
        string memory _booksString = "";
        for(uint i = 0; i < books.length; i++) {
            _booksString = string(abi.encodePacked(_booksString,books[i].title, ","));
        }
        return(_booksString);        
    }

    function borrowBookById(uint _bookId) external hasCopies(books[_bookId].copies) libraryContains(_bookId, books) {
        books[_bookId].copies -= 1;
        userToCurrentBorrows[msg.sender].push(_bookId);
        bookToBorrowers[_bookId].push(msg.sender);        
    }

    function returnBook(uint _bookId) external hasBook(msg.sender, _bookId) libraryContains(_bookId, books) {
        books[_bookId].copies += 1;
        userToCurrentBorrows[msg.sender].pop;
    }
    
    function findBorrowersByBookId(uint _bookId) external view returns(address[] memory) {
        return(bookToBorrowers[_bookId]);
    } 
}
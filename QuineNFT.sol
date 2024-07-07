//SPDX-License-Identifier: MIT
//Author: nix.eth
pragma solidity ^0.8.26;

event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event ContractURIUpdated(string newContractURI);

contract QuineNFT {
    address private _tokenOwner;
    address private _owner;
    address private _approved = address(0);
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    bytes16 private HEX_DIGITS = "0123456789abcdef";
    string private desc = '"description":"Is the algorithm itself or its outputs the art? Here it\'s both. \\n\\nThis contract renders its own Bytecode as an NFT. Completely on-chain, with no dependencies. \\n\\nLearn more: https://nix.art/quine","external_link":"https://nix.art/quine"';
    string private svgStart = ',"image":"data:image/svg+xml;base64,';
    string private jsonStart = 'data:application/json;base64,';
    string private svgOpen = '<?xml version="1.0" encoding="UTF-8"?><svg xmlns="http://www.w3.org/2000/svg" viewbox="0 0 ';
    string private styleOpen = '<style>text{fill:black;font-family:"Lucida Console",Monaco,monospace;font-size:';

    constructor() {
        _tokenOwner = msg.sender;
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
        emit Transfer(address(0), msg.sender, 0);
        emit ContractURIUpdated(contractURI());
    }

    function name() external pure returns (string memory){
        return "QuineNFT";
    }

    function symbol() external pure returns (string memory){
        return "QUINE";
    }

    function balanceOf(address _address) external view returns (uint256){
        if(_address == _tokenOwner){
            return 1;
        }
        return 0;
    }

    function owner() public view returns (address) {
        return _owner;
    }


    function ownerOf(uint256 _tokenId) external view returns (address){
        require (_tokenId == 0);
        return _tokenOwner;
    }

    function approve(address _newApproved, uint256 _tokenId) external{
        require (_tokenId == 0);
        _approved = _newApproved;
        require(msg.sender == _tokenOwner || isApprovedForAll(_tokenOwner, msg.sender));
        emit Approval(_tokenOwner, _newApproved, 0);
    }

    function getApproved(uint256 _tokenId) external view returns (address){
        require (_tokenId == 0);
        return _approved;
    }

    function setApprovalForAll(address _operator, bool _isApproved) external{
        require(_tokenOwner != _operator);
        _operatorApprovals[msg.sender][_operator] = _isApproved;
        emit ApprovalForAll(msg.sender, _operator, _isApproved);
    }

    function isApprovedForAll(address _address, address _operator) public view returns (bool){
        return _operatorApprovals[_address][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public{
        require(_tokenId == 0 && _from == _tokenOwner && _to != _from && _to != address(0));
        require(msg.sender == _tokenOwner || isApprovedForAll(_tokenOwner, msg.sender));
        _tokenOwner = _to;
        _approved = address(0);
        emit Transfer(_from, _to, 0);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory) public {
        safeTransferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        transferFrom(_from, _to, _tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == bytes4(0x80ac58cd) || interfaceId == bytes4(0x5b5e139f);
    }

    function _base64Encode(bytes memory data) private pure returns (string memory) {
        string memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        uint256 resultLength = 4 * ((data.length + 2) / 3);

        string memory result = new string(resultLength);

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 0x20)
            let dataPtr := data
            let endPtr := add(data, mload(data))
            let afterPtr := add(endPtr, 0x20)
            let afterCache := mload(afterPtr)
            mstore(afterPtr, 0x00)
            for {
            } lt(dataPtr, endPtr) {
            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            mstore(afterPtr, afterCache)
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }

        return result;
    }

    function _toString(uint _i) internal pure returns (string memory _uintAsString) {
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function _contractToSvg() private view returns (bytes memory) {
        bytes memory code = address(this).code;
        uint256 codeLen = code.length - 1;
        uint256 charsPerLine = codeLen / 82 + (codeLen % 82 == 0 ? 0 : 1);
        uint256 codeLenPad = charsPerLine * 82;
        uint256 outputLen = (codeLenPad * 2) + 5689;
        
        bytes memory output = new bytes(outputLen);

        uint cursor = 0;
        for (uint256 i = 0; i < codeLenPad; i++) {
            if(i%charsPerLine==0){
                uint256 line = i/charsPerLine + 1;
                bytes memory lineSep = abi.encodePacked('</text><text x="20" y="',_toString(line*24+15),'" textLength="1960" lengthAdjust="spacing">');
                for (uint k=line==1?7:0; k < lineSep.length; k++) {
                    output[cursor++] = lineSep[k];
                }
            }
            if(i <= codeLen){
                output[cursor++] = HEX_DIGITS[uint8(code[i]) / 16];
                output[cursor++] = HEX_DIGITS[uint8(code[i]) % 16];
            }else{
                output[cursor++] = '0';
                output[cursor++] = '0';
            }
        }

        return abi.encodePacked(svgOpen,'2000 2000" width="2000" height="2000">',styleOpen,'20px;}</style><rect width="2000" height="2000" fill="white"/>', output,'</text></svg>');
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        require(_tokenId == 0);
        string memory svg = _base64Encode(_contractToSvg());
        string memory uri = _base64Encode(abi.encodePacked('{"name":"Am I Art?",',desc,svgStart,svg,'"}'));

        return string(
            abi.encodePacked(
                jsonStart,
                uri
            )
        );
    }

    function contractURI() public view returns (string memory){
        string memory svg = _base64Encode(abi.encodePacked(svgOpen, '500 500" width="500" height="500">',styleOpen,'100px;}</style><rect width="500" height="500" fill="white"/><text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle">Quine</text></svg>'));
        string memory uri = _base64Encode(abi.encodePacked('{"name":"Quine; the self-serving art algorithm",',desc,svgStart,svg,'"}'));

        return string(
            abi.encodePacked(
                jsonStart,
                uri
            )
        );
    }
    /*
    function testLength() public view returns (uint256) {
        return address(this).code.length;
    }
    */
}
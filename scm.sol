pragma solidity ^0.5.17;
contract supplychain{
 
 address public manu;
 uint256 productUniqueId;
 
 constructor() public{
     productUniqueId = 1000;
     manu = msg.sender;
 }

modifier onlyManufacturer(){
    require(msg.sender==manu);
    _;
}

modifier onlyPartners(){
    for(uint i;i<partner.length;i++) {
        require(msg.sender ==partner[i]._partnerAddress);
    _;
    }
}

struct Mfg{
    bytes32 _mfgName;
    bytes32 _mfgLocation;
    address _mfgAddress;
}

Mfg[] public mfg;
mapping(address=>Mfg) getManufacturerByAddress;


struct Partner{
    bytes32 _partnerName;
    bytes32 _partnerLocation;
    bytes32 _roles;
    bytes32 _stage;//supplier=2,assemblier(manufacturer)=3,distributor=4,retailor=5
    bytes32 _handle;//screen,battery,motherboard,assemblier,distributor,retailor
    address _partnerAddress;
}

Partner[] public partner;
mapping(address => Partner) public getByPartnerAddress;

struct Product{
    uint256 _productId;
    bytes32 _productName;
    bytes32[] _productState; // initiate-1,rawmatrial-2, assembler-3,distributor-4,retailor-5
    bytes32[] _productTimeStamp;//when
    address[] _partnerAddress;//who
    bytes32[] _handle;
}
Product[] public product;
mapping(uint256 =>Product) public getByProductId;


function addManufacturer(bytes32 _mfgName,bytes32 _mfgLocation,address _mfgAddress) public onlyManufacturer(){

Mfg memory _mfg = Mfg(_mfgName,_mfgLocation,_mfgAddress);
mfg.push(_mfg);
getManufacturerByAddress[_mfgAddress]= _mfg;
    
}

function verifyManufacturer(address verifyMfgAddress)public view returns(bytes32 _mfgName,bytes32 _mfgLocation,address _mfgAddress){
    
    for(uint i;i<mfg.length;i++){
        if(mfg[i]._mfgAddress == verifyMfgAddress){
            return(mfg[i]._mfgName,mfg[i]._mfgLocation,mfg[i]._mfgAddress);
        }
    }

    
} 


function addPartner(bytes32 _partnerName,bytes32 _partnerLocation,bytes32 _roles,bytes32 _stage,bytes32 _handle,address _partnerAddress) public onlyManufacturer(){
    Partner memory _partner = Partner(_partnerName,_partnerLocation,_roles,_stage,_handle,_partnerAddress);
    partner.push(_partner);
    getByPartnerAddress[_partnerAddress]=_partner;
    
}

// function verifyPartner(address verifyPartnerAddress)public view returns(bytes32 _partnerName,bytes32 _partnerLocation,bytes32 _roles,address _partnerAddress){
//     for(uint i;i<partner.length;i++){
//         if(partner[i]._partnerAddress == verifyPartnerAddress){
//             return(partner[i]._partnerName,
//                   partner[i]._partnerLocation,
//                     partner[i]._roles,
//                     partner[i]._partnerAddress);
            
//         }
//     }
// }

function getAllPartners() public view returns (bytes32[] memory, bytes32[] memory,bytes32[] memory,bytes32[] memory,bytes32[] memory,address[] memory){
    bytes32[] memory _partnerNames = new bytes32[](partner.length);
    bytes32[] memory _partnerLocations = new bytes32[](partner.length);
    bytes32[] memory _partnerroles = new bytes32[](partner.length);
    bytes32[] memory _partnerstages = new bytes32[](partner.length);
    bytes32[] memory _partnerhandles = new bytes32[](partner.length);
    address[] memory _partnerAddresses = new address[](partner.length);
    
    for(uint i=0;i<partner.length;i++){
        (_partnerNames[i]=partner[i]._partnerName,
        _partnerLocations[i]=partner[i]._partnerLocation,
        _partnerroles[i]=partner[i]._roles,
        _partnerstages[i]=partner[i]._stage,
        _partnerhandles[i]=partner[i]._handle,
       _partnerAddresses[i]= partner[i]._partnerAddress);
    }
    return(_partnerNames,_partnerLocations,_partnerroles,_partnerstages,_partnerhandles,_partnerAddresses);
    
}

function editPartner(bytes32 _partnerName,bytes32 _partnerLocation,bytes32 _roles,bytes32 _stage,bytes32 _handle,address _partnerAddress) public onlyManufacturer(){

    for(uint i;i<partner.length;i++){
        if(partner[i]._partnerAddress==_partnerAddress){
            partner[i]._partnerName = _partnerName;
            partner[i]._partnerLocation = _partnerLocation;
            partner[i]._roles = _roles;
            partner[i]._stage=_stage;
            partner[i]._handle=_handle;
            partner[i]._partnerAddress = _partnerAddress;
        }
    }    
    
}
function addProduct(uint256 _productId,
                    bytes32 _productName,
                    bytes32[] memory _productState,
                    bytes32[] memory _productTimeStamp,
                    address[] memory _partnerAddress,
                    bytes32[] memory _handle) public onlyManufacturer(){
    Product memory _product =Product(productUniqueId++,_productName,_productState,_productTimeStamp,_partnerAddress,_handle);
    product.push(_product);
    getByProductId[_productId]=_product;
    //emit productIdadded(productsId);
    //productsId++;
    }

function verifyProduct(uint256 verifyProductId) public view returns
(uint256 _productId,bytes32 _productName,bytes32[] memory _productState,bytes32[]memory _productTimeStamp,
address[] memory _partnerAddress,bytes32[] memory _handle){
    
    for(uint i; i<product.length;i++){
        if(product[i]._productId == verifyProductId){
            return(product[i]._productId,
            product[i]._productName,
            product[i]._productState,
            product[i]._productTimeStamp,
            product[i]._partnerAddress,
            product[i]._handle);
        }
    }
}
    
function updateProduct(uint256 _productId,
                    bytes32 _productName,
                    bytes32[] memory _productState,
                    bytes32[] memory _productTimeStamp,
                    address[] memory _partnerAddress,bytes32[] memory _handle) public onlyPartners() {
    //for(uint i;i<product.length;i++){
       // if(product[i]._productId==_productId) {
            if((product[_productId]._productState==getByPartnerAddress[msg.sender]._stage) && (product[_productId]._handle ==getByPartnerAddress[msg.sender]._handle)){
                product[_productId]._productName = _productName;
                product[_productId]._productState = _productState;
                product[_productId]._productTimeStamp = _productTimeStamp;
                product[_productId]._partnerAddress = _partnerAddress;
                product[_productId]._handle=_handle;
            }
        
    }
      
    //Product memory _product = Product(productUniqueId++,_productName,_productState,_productTimeStamp,_partnerAddress,_handle);
    //product.push(_product);
   //getByProductId[_productId]=_product;


    
    
    
}
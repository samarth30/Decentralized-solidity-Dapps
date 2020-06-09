pragma solidity ^0.5.0;

contract Supplier{
    // number of suppliers
    uint public CountSupplier;
    
    // total number of orders
    // uint256 public TotalNumberOfOrder;
    
    // stuct of Supplier
    struct Supplierr{
        uint id;
        address payable supplierAdress;
        uint256 noOfProducts;
        uint256 price;
        string productName;
        string supplierLocation;
    }
    
    // event for supplier to notify
    event SupplierCreated(
        uint id,
        address supplierAdress,
        uint256 noOfProducts,
        uint256 price,
        string productName,
        string supplierLocation
    );
    
    // struct of customer
    // struct CustomerOrder{
    //     address customerAdress;
    //     uint256 noOfProductsOrdered;
    //     string customerLocation;
    //     string product;
    // }
    
    event CustomerOrdered(
        address customerAdress,
        uint256 noOfProductsOrdered,
        string product,
        string customerLocation
    );
    
    // enrolling suppliers
    mapping(uint => Supplierr) public suppliers;
    // order the suppliers
    
    
    function registerSupplier(uint _noOfProducts,uint _price,string calldata _productName,string calldata _location) external{
        // check wether the supplier is registerd or h
        // require(
        // keccak256(abi.encodePacked(suppliers[msg.sender].productName)) != 
        // keccak256(abi.encodePacked(_productName)),
        // "the address is allready registerd");
        // check the supplier location , no of product and name of product to be valid
        require(_noOfProducts > 0);
        require(bytes(_productName).length > 0);
        require((bytes(_location).length)>0);
        
        // increase the countSupplier
        CountSupplier +=1;
        
        suppliers[CountSupplier] = Supplierr(CountSupplier,msg.sender,_price,_noOfProducts,_productName,_location);
        emit SupplierCreated(CountSupplier,msg.sender,_noOfProducts,_price,_productName,_location);
    }
    
    function addProducts(uint _id,uint _noOfProducts,uint _price) external{
        Supplierr memory _supplierr = suppliers[_id];
        require(_supplierr.id == _id);
        require(_supplierr.supplierAdress == msg.sender);
        _supplierr.noOfProducts += _noOfProducts;
        
        if(_price != 0){
        _supplierr.price = _price;
        }
        suppliers[_id] = _supplierr;
        emit SupplierCreated(_id,msg.sender,suppliers[_id].noOfProducts,suppliers[_id].price,suppliers[_id].productName,suppliers[_id].supplierLocation);
    }
    
    function mul(uint a,uint b) public pure returns(uint){
        return a*b;
    }
    
    function OrderProducts(uint _id,uint _noOfProducts,string calldata _location) external payable {
        Supplierr memory _supplier = suppliers[_id];
        // the _id is correct
        require(_supplier.id == _id);
        // // the supplier has stock
        require(_supplier.noOfProducts >= _noOfProducts);
        // the locatioin should be same
        require(
        keccak256(abi.encodePacked(_supplier.supplierLocation)) == 
        keccak256(abi.encodePacked(_location)),
        "the locality is different");
        // require(supplier[_adress] == id);
        require(msg.value >= (_supplier.price*_noOfProducts));
        // has balance
        _supplier.noOfProducts = _supplier.noOfProducts - _noOfProducts;
        // get the address
        address payable _seller = _supplier.supplierAdress;
        
        suppliers[_id] = _supplier;
        
        address(_seller).transfer(msg.value); 
        
        emit CustomerOrdered(msg.sender,_noOfProducts,suppliers[_id].productName,_location);
    }
    
    
    
}  

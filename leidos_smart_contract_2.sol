pragma solidity ^0.5.12;

contract asset_management {
    enum condition_code {OK, DAMAGED, EXPENDED, DESTROYED, LOST, UNKNOWN}

    //asset lifecycle events
    //create/update_handling/update_storage/ship/update_gps/receive/transfer/update_storage/delete - update_condition
    event asset_created(string serial_number, uint asset_IUIDtag, string asset_NSN, condition_code asset_condition_code, uint asset_created_count, uint asset_count_total, uint assets_in_storage, uint assets_in_transit, uint asset_deleted_count);
    event asset_handling_update(string serial_number, string curr_UIC, string curr_RIC, string curr_account_code);
    event asset_storage_update(string serial_number, string curr_ACC, string curr_lot_number, string curr_stock_number);
    event asset_shipped(string serial_number, string from_UIC, string to_UIC, string new_RDD, uint assets_in_storage, uint assets_in_transit);
    event asset_transit_update(string serial_number, bool asset_in_transit);
    event asset_gps_shipment_coordinates_update(string serial_number, string gps_coordinates);
    event asset_received(string serial_number, string receiving_UIC, string receiving_RIC, string receiving_account_code, string receiving_ACC, uint assets_in_transit, uint assets_in_storage);
    event asset_transferred(string serial_number, string from_acc, string to_acc);
    event asset_condition_code_updated(string serial_number, condition_code asset_condition_code);
    event asset_deleted(string serial_number, uint asset_created_count, uint asset_count_total, uint asset_deleted_count, uint assets_in_transit, uint assets_in_storage);

    // asset exception error events
    event failed_asset_existence(string serial_number, string message);
    event failed_asset_update(string serial_number,  uint asset_IUIDtag, string message);

    // violation events
    event temperature_violation(string serial_number, uint asset_IUIDtag, int value, uint time);
    event humidity_violation(string serial_number, uint asset_IUIDtag, int value, uint time);
    event geo_violation(string serial_number, uint asset_IUIDtag, string latitude, int latitude_value, string longitude, int longitude_value, uint time);
    
    struct asset_attr {

        //variable to check for the existence of a given asset mapping
        bool exists;
        
        /////////////////////// asset identification, condition, and transit state info ///////////////////////
        // Asset unique identification (IUID)
        uint IUIDtag;

        // National Stock Number of asset
        string NSN;
        
        // Current condition of asset
        condition_code code;

        // Asset indicator if in transit
        bool in_transit;
        ////////////////////////////////////////////////////////////////////////////////////////

        /////////////////////// asset handling info /////////////////////////
        // Unit identification code who either currently has the physical asset or will receive the asset in shipment
        string UIC;

        // A 3-character, alpha-numeric code that uniquely identifies a unit, activity, or organization that requires system ability to route asset transactions or receive asset transactions
        string RIC;

        // Account type with possession of the asset
        string account_code;
        /////////////////////////////////////////////////////////////////////

        /////////////////////// asset storage location info /////////////////////////
        //  Stationary physical location code of asset storage
        string ACC;

        // Lot number where asset is stored, for physical storage
        string lot_number;

        // Stock number of asset on lot, for physical storage
        string stock_number;
        /////////////////////////////////////////////////////////////////////////////

        /////////////////////// asset shipping info /////////////////////////
        //GPS coordinates of asset on shipment route
        string GPS_shipment_coordinates;

        // Code of the type of asset being transported.
        string transportation_code;

        // Contract identifier between the asset shipping and receiving parties
        string transportation_contract_number;

        // Required delivery date of asset
        string RDD;
        ////////////////////////////////////////////////////////////////////////////////////
    }

    struct VT_Pair{

        // value
        int value;
        
        // epoch time
        uint time;
    }

    struct Geo_Pair{
        
        // latitude information: n for north s for south
        string latitude;
        int latitude_value;
        
        // longitude information: w for west e for east
        string longitude;
        int longitude_value;
        
        uint time;
    }
    
    struct Record{
        
        // Sizes of various violations
        uint humidity_violation_size;
        uint temp_violation_size;
        uint geo_violation_size;
        
        // Violation pair arrays
        VT_Pair[] humidity;
        VT_Pair[] temp;
        Geo_Pair[] geo;
    }

    uint assetCountTotal;
    uint assetsInTransit;
    uint assetsInStorage;
    uint assetsCreatedCount;
    uint assetDeletedCount;
    mapping(string=>asset_attr) assetStruct;
    mapping(string => Record) violations;
 
    constructor() public {
       assetCountTotal = 0;
       assetsInTransit = 0;
       assetsInStorage = 0;
       assetsCreatedCount = 0;
       assetDeletedCount = 0;
    }

    function create_new_asset(string memory serial_number, uint asset_IUIDtag, string memory asset_NSN, condition_code asset_condition_code)
    public returns (bool success) {

        //if asset with serial number already exists, emit failure event
        if (assetStruct[serial_number].exists == true) {
            emit failed_asset_existence(serial_number, "create_new_asset Failed: Asset already exists.");
            return false;
        }
        //asset cannot be created with EXPENDED or DESTROYED condition code, emit failure event
        else if (asset_condition_code == condition_code.EXPENDED || asset_condition_code == condition_code.DESTROYED) {
            emit failed_asset_update(serial_number, asset_IUIDtag, "create_new_asset Failed: Cannot create Asset with condition (2 - EXPENDED) or (3 - DESTROYED).");
            return false;
        }
        //create asset, emit success event
        else {
            assetStruct[serial_number].exists = true;
            assetStruct[serial_number].IUIDtag = asset_IUIDtag;
            assetStruct[serial_number].NSN = asset_NSN;
            assetStruct[serial_number].code = asset_condition_code;

            //increment created and total counter
            assetsCreatedCount += 1;
            assetCountTotal += 1;

            //emit created asset
            emit asset_created(serial_number, asset_IUIDtag, asset_NSN, asset_condition_code, assetsCreatedCount, assetCountTotal, assetsInStorage, assetsInTransit, assetDeletedCount);
            return true;
            //to complete asset create, update handling and storage
        }
        
        
    }
    
    
    function getItemCount() public view returns (uint){
            return assetCountTotal;
    }

   

    

    
    


    
}

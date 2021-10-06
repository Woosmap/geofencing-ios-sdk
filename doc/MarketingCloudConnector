## Salesforce Marketing Cloud Integration
  
Generate contextual events from Geofencing SDK data using different event types: Geofences, POI, Visits and ZOI.

Whenever location events are generated, the Geofencing SDK will send custom events and properties to your App via a delegate protocol. Your App can then pass data to the Marketing Cloud.

To push event data to the Salesforce Marketing Cloud API, and [Fire a Entry Event](https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-apis.meta/mc-apis/how-to-fire-an-event.htm), subscribe to SDK callbacks and implement API call in it, or simply initialize the Marketing Cloud connector to let the Geofencing SDK run API call to push event data.  

### Set up Marketing Cloud events 
The first step in sending custom events to MarketingCloud is to set `MarketingCloudEventsDelegate`, this should be done as early as possible in your didFinishLaunchingWithOptions App Delegate.

```swift
let marketingCloudEvents = MarketingCloudEvents()

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Set delegate of protocol Marketing Cloud events
        WoosmapGeofencing.shared.getLocationService().marketingCloudEventsDelegate = marketingCloudEvents

``` 
## Retrieve Marketing Cloud events
In your class delegate, retrieve custom events data.

### Enter/Exit a monitored region

Event name: `woos_geofence_entered_event`<br/>
Event description: This event is triggered when the device enters in a POI’s region.

Event name: `woos_geofence_exited_event`<br/>
Event description: This event is triggered when the device exits in a POI’s region.

**Event data specification**

| Field name                       | Type   | Only if the region is a POI |
| -------------------------------- | ------ | --------------------------- |
| date                             | Datetime   |                             |
| id                               | String |                             |
| latitude                         | Double |                             |
| longitude                        | Double |                             |
| radius                           | Double |                             |
| name                             | String | X                           |
| idStore                          | String | X                           |
| city                             | String | X                           |
| zipCode                          | String | X                           |
| distance                         | String | X                           |
| country\_code                    | String | X                           |
| address                          | String | X                           |
| tags                             | String | X                           |
| types                            | String | X                           |
| user\_properties\_\[field\_name\] | String | X                           |

**Callback implementation**
``` swift
public class MarketingCloudEvents: MarketingCloudEventsDelegate {
    
    public init() {}
    
    public func regionEnterEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add your data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": regionEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
        
    }

    public func regionExitEvent(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": regionEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
        
    }
}
```

### POI

Event name: `woos_POI_event`<br/>
Event description: This event is triggered when the device retrieves nearest POI data from WoosmapSearch API      

**Event data specification**

| Field name                       | Type   |
| -------------------------------- | ------ |
| date                             | Datetime   |
| name                             | String |
| idStore                          | String |
| city                             | String |
| zipCode                          | String |
| distance                         | String |
| country\_code                    | String |
| address                          | String |
| tags                             | String |
| types                            | String |
| user\_properties.\[field\_name\] | String |

**Callback implementation**
``` swift
public class MarketingCloudEvents: MarketingCloudEventsDelegate {
    
    public init() {}
    
    public func poiEvent(POIEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": POIEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
    }
}
```

### Visits detection event

Event name: `woos_Visit_event`<br/>
Event description: This event is triggered when the device detects a visit

**Event data specification**

| Field name    | Type     |
| ------------- | -------- |
| date          | Datetime |
| arrivalDate   | Datetime |
| departureDate | Datetime |
| id            | String   |
| latitude      | Double   |
| longitude     | Double   |

**Callback implementation**
``` swift
public class MarketingCloudEvents: MarketingCloudEventsDelegate {
    
    public init() {}
    
    public func visitEvent(visitEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": visitEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
    }
}
```

### Classified ZOI detection event

Event name: `woos_zoi_classified_entered_event`<br/>
Event description: This event is triggered when the device enters in a classified ZOI

Event name: `woos_zoi_classified_exited_event`<br/>
Event description: This event is triggered when the device exits in a classified ZOI

**Event data specification**

| Field name | Type   |
| ---------- | ------ |
| date       | Datetime   |
| id         | String |
| latitude   | Double |
| longitude  | Double |
| radius     | Double |

**Callback implementation**
``` swift
public class MarketingCloudEvents: MarketingCloudEventsDelegate {
    
    public init() {}
    
    public func ZOIclassifiedEnter(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": regionEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
    }
    
    public func ZOIclassifiedExit(regionEvent: Dictionary<String, Any>, eventName: String) {
        // here you can modify your event name and add data in the dictonnary
        
        let body : [String: Any] = ["ContactKey": "ID001",
                                    "EventDefinitionKey":"APIEvent-1b15b73a-cd8f-e508-efbe-6040061e9c51",
                                        "Data": regionEvent
                                        ]
        self.sendRequestToSFMC(poiData: body) 
    }
}
```

## Initialize the Marketing Cloud connector
The SDK needs some input like credentials and object key to perform the API call to Salesforce Marketing Cloud API.

**Input to initialize the SFMC connector**<br/>

| Parameters                             | Description                                                                                               | Required |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------- | -------- |
| authenticationBaseURI                  | Authentication Base URI                                                                                   | Required |
| restBaseURI                            | REST Base URI                                                                                             | Required |
| client\_id                             | client\_id (journey\_read and list\_and\_subscribers\_read rights are required)                           | Required |
| client\_secret                         | client\_secret (journey\_read and list\_and\_subscribers\_read rights are required)                       | Required |
| contactKey                             | The ID that uniquely identifies a subscriber/contact                                                      | Required |
| regionEnteredEventDefinitionKey        | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_geofence_entered_event`       |          |
| regionExitedEventDefinitionKey         | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_geofence_exited_event`        |          |
| poiEventDefinitionKey                  | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_POI_event`                    |          |
| zoiClassifiedEnteredEventDefinitionKey | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_zoi_classified_entered_event` |          |
| zoiClassifiedExitedEventDefinitionKey  | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_zoi_classified_exited_event`  |          |
| visitEventDefinitionKey                | Set the EventDefinitionKey that you want to use for the Woosmap event `woos_Visit_event`                  |

**Initialize the connector implementation**
``` swift
WoosmapGeofencing.shared.setSFMCCredentials(credentials : [ 
          "authenticationBaseURI": "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.auth.marketingcloudapis.com",
          "restBaseURI": "https://mcdmfc5rbyc0pxgr4nlpqqy0j-x1.rest.marketingcloudapis.com",
          "client_id": "xxxxxxxxxxxxxxx",
          "client_secret": "xxxxxxxxxxxxx",
          "contactKey":"ID001",
          "regionEnteredEventDefinitionKey":"APIEvent-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
          "regionExitedEventDefinitionKey":"APIEvent-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
          ])
```

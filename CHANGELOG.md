# Changelog

## 2.2.0 (2017-01-13)

### Added
*	New search bar added, accessible also with "/" slash hot key. You can find client, invoice, payment and even help article using a key word such as client id, email, IP address, invoice id, etc.
*	You can also search archived clients by name, address, service IPs, etc.
*	While setting up HTTPS, you can now upload the CA bundle file along with your cert file.
*	Information about client's recurring payment subsriptions are shown in client detail page
*	API enhanced. You can retrieve all clients and all services, or get entities by their id
*	You can manually create and download up-to-date database backup (in System > Tools)
*	Old device backup files are pruned. Last 14 backups are kept in UCRM after each synchronization.

### Changed
*	Now, you can define tax value with up to 4 decimal places
*	SNMP community string limited to 32 chars

### Fixed
*	Mailer spool fixed in case there is a mail pending with invoice pdf previously removed
*	Fixed possible bug with connection to elastic container after UCRM update
*	Synchronization with older edgeOs devices improved
*	Client sorting by id fixed
*	Fixed automated netflow set up. (For some devices, the netflow could have remained in pending state)
*	Minor bugs fixed

## 2.1.12 (2017-01-04)

### Added
*	IP of terminated service is blocked on the router
*	UCRM update process improved. In case of a failure the previous version is restored.
*	Demo-mode termination improved. You can now mark all clients as not invited and all existing invoices as not sent while terminating the demo-mode.
*	While adding a new service, you will see a warning that prorating will be applied (to prevent situation when "period start day" does not match with "invoicing start" by mistake)
*	Period start day is shown on service detail page
*	Better price and quantity validation added to the new invoice form (you can use both . and , as the decimal separator)
*	UCRM API improved. When adding a new payment, it can be matched with multiple invoices.
*	UI improvements

### Changed
*	Settings structure simplified. Main settings can be found in System > Settings. All billing parameters can be found together under System > Billing. Service plans, products and surcharges are moved under System > Items, etc.
*	DB backup simplified. You don't need to move the crypto.key while backuping or restoring UCRM database.
*	Prepared service cannot be suspended or terminated, related buttons are hidden now.
*	Invoices of archived clients are visible in the global invoice list.
*	Special permission "View financial information" affects client's financial overview and also financial overview on Dashboard now
*	Client IP not shown on walled garden suspend page unless stated explicitly using client IP placeholder in notification settings
*	Support email is shown in client-zone instead of organization email when available

### Fixed
*	Fixed outgoing invoice emails for recurring invoices (some smtp servers affected)
*	Bugs regarding invoice preview fixed in new service form
*	Default client's taxes are properly applied when creating a new invoice
*	All the client's services are shown in client zone (only the first 5 services were shown before)
*	$0 individual service price can be set now
*	Fixed inconvenient issues when user has insufficient permissions
*	PayPal error is handled properly and logged
*	Fixed minor bugs

## 2.1.11 (2016-12-16)

### Fixed
*	Fixed shaping on AirOs devices
*	When shaping is turned off on EdgeOs devices or globally in system settings, UCRM will not even connect to any EdgeOs
*	Client and service status are updated immediately after any change
*	Fixed possible bug with resolving gps coordinates
*	While creating a new invoice manually, late fees select box shows only those items which belongs to the given client
*	Minor UI, UX fixes and app speed improvements

## 2.1.10 (2016-12-14)

### Added
*	Client suspended badge added to the clients grid
*	Grids page size is remembered
*	Now, you can search invoices by their number
*	You can set default invoice note (comment) at organization > billing options. This note will be automatically added to every new invoice.

### Changed
*	Association of suspend, overdue and outage badges to clients / services is no longer pushed to system log
*	Good news for those who need custom bank account number. You can use just the first field, the second field can be left empty and no slash will be displayed.
*	Credit is now applied to an invoice in proper order (payments associated to the invoice are used from oldest to newest)

### Fixed
*	Fixed item counts and pagination for some grids
*	UI fixes for Safari browser
*	Invoice number generator fixed when non-numeric prefixes are used
*	Shaping fixed on some EdgeRouters which already used own shaping rules
* Fixed log entries for mailer errors
* Minor UI / UX fixes and improvements

## 2.1.9 (2016-12-12)

### Added
#### UX & redesign
*	Major UI, UX improvements. Mostly for client, service detail and all grids.
*	You can now filter and export clients and invoices into csv file.
*	Status tags in clients and invoices grid. At first sight, you will see an outage or overdue status at your client or invoice.
*	Now, you can search clients by their service device IP and also search network device by its IP
*	You can filter overdue invoices now

#### Shaping
*	Shaping enabled on EdgeRouters
*	If you are used to shape on your gateway router only, you can simply turn this feature on, applied to all the clients globally - in system settings.
*	If shaping on AirOs CPE devices you can choose whether to shape egress only (on wlan and lan) or egress, ingress (on wlan)

#### Other
*	Now you can specify a check number when creating a new check payment
*	More details about incoming payment from paygates are now provided in payment detail page
*	Client is enabled to modify the amount to be paid when paying online and decide to associate it with multiple invoices or to turn it into credit.
*	As a WISP, when creating a new payment you can associate it with multiple invoices
*	API upgraded - you can upload a payment with a third party paygate information.
*	GPS address is automatically resolved when creating a new service according to the client location

### Changed
*	Improved grids, filtering and related action buttons
*	Better email queue handling and error monitoring
*	Same invoice number can be used within more UCRM organizations.
*	"Quick add device" feature improved. No fictive interface is created after the first device synchronization.
*	Service taxable flag removed, since it is redundant. When some tax is associated with the service it is taxable by default
*	Major app speed improvements
*	PHP updated to v. 7.0.14

### Fixed
*	Fixed bug when tariff period being updated with empty price
*	Options for service periods rendered properly in edit service form, only valid periods related to a given service plan are shown now.
*	Fixed rendering of invoice pdf with organization logo and stamp
*	Now, the value of client's invoice maturity days overrides properly the global value set in system settings.
*	Fixed problem with outgoing outage notifications (occurred on some smtp servers)
*	Fixed possible problems with editing taxes or periods on a service
*	Now, client's taxes are automatically applied to "product" invoice item
*	$0 balanced invoices of all kinds are not sent if defined so in system settings
*	Fixed matching of subscription payments with the invoice. Some payments from paygates were marked as unmatched although it was possible to match them with an invoice automatically
*	Minor fixes and improvements

## 2.1.8 (2016-11-24)

### Changed
*	Proper paypal exception hadnling, user is notified to contact the ISP to solve the problem.
*	PHP bumped to v7.0.13

### Fixed
*	Fixed RouterOs synchronization
*	Suspended service's IPs are correctly propageted to BLOCKED_USERS list even when the service is connected to a device with disabled suspension feature
*	IPs list on interface properly synchronized. Multiple duplacate IPs are not longer created during the sync.
*	Fixed possible bug with applying client's credit to invoice.
*	Fixed outgoing notification emails in case of reapeated outages.
*	Fixed turning off the outage notification feature in system settings

## 2.1.7 (2016-11-09)

### Added
* UCRM API - new api for payments and invoices. You can upload new payments of any source and an invoice with simplified items

### Changed
* UCRM API improved - client's service entity now contains info about service plan and shaping speed

### Fixed
* Payment subscribe button shown properly in client zone (even for invioces with surcharges and taxes)


## 2.1.6 (2016-11-08)

### Fixed

*	Payment subscribe button shown properly in client zone
*	Invoices Batch print and Export button works now
*	"Drafts created" notification sent only when there is at least one new invoice
*	Disappearing menu items on some subpages fixed
*	Minor fixes for sync feature and authorize.net subscribtions handling

### Changed
*	Invoice preview (in new service form) shows total price including tax
*	While device sync, its interfaces types are set according to real interface type (wlan, ethernet, etc.)
*	Improved stability for restoring db backup

## 2.1.5 (2016-11-04)

### Added
*	UCRM API - this will enable you to mass-upload clients, services and some other main entities into UCRM. See more at http://docs.ucrm.apiary.io/
*	Subscribtions for recurring payments on Authorize.Net now available
*	EdgeOs vlan interfaces are automatically created and synchronized now
*	Filter payments by amount or client's name, email, etc.
*	You can upload file into webroot directory using UCRM interface in Settings > Tools > Webroot
*	UCRM Maintenance page shown when db backup is being restored
*	Kenyan shillings added to currency list

### Changed
*	Safe upgrade. When database migration fails during the update it is reverted to the previous state and the UCRM version is not upgraded.
*	Shaping on AirOs now accept float values. You can set up 4.25 Mbps
*	Better interface for netflow turns on/off on EdgeRouters
*	Better tooltips for sites and services on maps
*	UI performance improved

### Fixed
*	Free service plans (with billing period for 0$) can be created now
*	0$ invoice status fixed to be paid
*	Zero price in service is allowed
*	Fixed service next invoicing day shown in client zone
*	Fixed possible problem with matching / unmatching payment to invoice
*	Fixed default submit button in grid fiters
*	Problem with AirCRM data import fixed
*	Possible problem with searching fixed
*	Device synchronization logs are now displayed in correct order
*	Automatic change of server ports after activating HTTPS is now working correctly
*	When encryption key is incorrect after database restore, you should now still be able to access web interface

## 2.1.4 (2016-10-19)

### Changed
* PHP updated to v7.0.12

### Fixed
* Fixed EdgeOS connection problem with socket script upload.
* Fixed failing migration at container start.
* Fixed bug with credit being applied incorrectly after invoice was voided.
* Fixed missing validation of notification template subject.
* Fixed wrong input type for frequency on device interface form.
* Fixed wrong application help permissions (only worked for super admin, instead of all admins).
* Fixed searching in device list.
* Fixed a bug in IP validation preventing creation of service device IP.
* Fixed wrong redirect after payment was deleted on clients billing screen.
* Fixed logging of changes after device synchronization.
* Fixed a bug in AirOS device synchronization.

## 2.1.3 (2016-10-17)

### Fixed
* Fixed QoS (traffic shaping) synchronization for AirOS CPEs.
* Fixed marking devices offline after automatic addition of device interfaces.
* Fixed SSH port getting overwritten on device edit page.
* Fixed amount of synchronization log entries.
* Fixed synchronization not happening immediatelly when needed.
* Fixed errors around soft deleted entities.
* Fixed couple of UI errors.

## 2.1.2 (2016-10-11)

### Fixed
* Fixed payment rounding error. (Fixes partially paid invoices, which should be marked as paid.)
* Fixed automatic sending of invoices.
* Fixed possible problem with cache after UCRM update.

## 2.1.1 (2016-10-07)

### Added
* Encryption key donwload feature added in Settings > Tools > Database backup. Note that while migrating a new server or to reinstalled UCRM instance, you must always migrate db along with the encryption key or all the passwords stored in the db will be unreadable.
* Interfaces of type "Bridge" are now created automatically when device is synchronized

### Changed
* You can hide unsuccessful NetFlow setup tries in System Settings
* While synchronization, UCRM tries to connect to a device with only one accessible IP (if there are more accessible IPs on a device, the last successful is used. The inaccessible IPs are skipped by default. Make sure each device as at least one accessible IP)
* Setting up NetFlow is disabled until the UCRM Server IP is properly set (in Settings > General > System > Application)
* App integrated help guide improved

### Fixed
* Possible migration failure fixed (followed by crashes of multiple pages)
* Invoice numbers auto increment fixed
* Excesive log entries fixed in case of unsuccessful NetFlow setup
* Synchronization of device interfaces fixed (non existing interfaces which don't match with any real device interface are removed). See more about the matching rules in the app guide.
* Fixed crashes when trying to delete late fee which has been already invoiced
* Fixed crashes when removing Device, ServiceDevice or User with existing log entries or statistics
* Fixed validations in invoice form
* Other minor fixes

## 2.1.0 (2016-09-30)

### Added
#### Network features
* NetFlow - view download and upload data traffic of your clients
* Device synchronization - device attributes such as interfaces, IPs and many more are now automatically and periodically updated according to the physical device configuration (for EdgeOs, AirOs, RouterOs devices)
* Quick autoload af a device - whenever you need to add new device to UCRM, just provide IP, username and password and UCRM will automatically set up other attributes for you, e.g. interfaces and IPs (for EdgeOs, AirOs, RouterOs devices)
* Device statistics - you can monitor the state of your devices thanks to new charts for Signal, CCQ, Rx and Tx rates, ping latency and loss rate (for AirOs, EdgeOs, RouterOs devices)
* Device outages - view device outages log and define who and when should be notified in case of an outage (for all vendors and models)
* QoS - set up the traffic shaping (current implementation: shaping on AirOs CPE devices is now available)
* View of unknown connected devices as an outcome of netflow and synchronization features. Devices which don't belong to any client but they are connected to routers or have upload/download traffic are now detected.
#### App features
* Organization logo and site name is now shown on login page. Additionally, the site name is shown in the client-zone page headers
* Now you have full control of your client registration status. These are possible values: Not invited, Invited on.., Registered on..
* Google maps and Google geocoding are now supported. Follow the setup guide in UCRM system settings.
* SMTP setup added to the initial setup wizard
* Now, you can upload and restore a database backup of any previous UCRM version
* An overview of invoices to be send is now displayed when clicked on batch invoice sending
* Now, you can search sites and devices by names (including partial name), addresses, vendors or model names
* Application-wide help and guides are now available - click on ? sign
* Various form field validations added

### Changed
* Suspension feature can be enabled on specified router devices now. It is turned off by default, choose which device should manage the suspension and turn it on in device edit page.
* Emails are now case insensitive - you can log in using name@examle.com or Name@EXAMPLE.com
* IP in CIDR format can no longer have netmask lower than 8
* Association between client service and network device is optional now. However, if you want to to use all current and future network features, it is recommended to link client service to a connect point network device)
* More user friendly log messages
* PHP updated to v7.0.11

### Fixed
* Stripe payment rounding error fixed
* Possible problems with system settings options now fixed (suspension feature could be still active although it had been switched off in system settings)
* CSV import bug fixed
* Position of button for Save invoice and Send invoice has been fixed
* Suspended service count fixed on homepage
* Fixed payment receipt email sending
* Suspend synchronization fixed after a new payment is added, client is correctly unsuspended in a few secs
* Email connection check fixed
* Problems when closing some modal windows and other minor UI fixes

## 2.0.14 (2016-09-07)

### Changed
* Various form validations added to avoid crashes
* Better confirmation dialog when demo mode is terminated

### Fixed
* Stripe payments passed to UCRM corretly now
* Invoice preview fixed and other UI fixes
* Minor fixes

## 2.0.13 (2016-08-30)
### Changed
* PHP updated to v. 7.0.10

### Fixed
* Crashes when creating invoices and approving drafts fixed
* Bug fixed when creating services after organization has been deleted

## 2.0.12 (2016-08-19)

### Added
* Payment receipts - You can send receipts manually or set up automatic receipts for incomming online payments (billing settings)
* Various form validations
* System logs enhancements

### Fixed
* Crashes while creating invoices fixed
* Minor fixes


## 2.0.11 (2016-08-16)

### Added
* Demo mode - enabling you to set real life data within a sandbox and test the app (clients will not be notified) Then launch the app to production mode
* Custom invoicing period start day (per client, per service)
* Help panel explaining invoicing parameters (click the tooltip icons on new service page)
* UCRM Time zone - you can set your local time zone in Settings > General > System

### Fixed
* Service status displayed correctly (suspended - red, terminated- grey)
* SSL redirect to custom port fixed (follow the knowledge base guide)
* Minor bug fixes


## 2.0.10 (2016-07-29)

### Fixed
 * Fixed client archive UI
 * Fixed cache permissions bug
 * Fixed service discount dates selection

## 2.0.9 (2016-07-28)

### Added
* Client init id number - new id is suggested automatically according to the last id used within the given organization
* You can now choose which rows to import in CSV import tool
* First and last name added to admin users
* MapBox satellite view
* Added AOA currency support

### Changed
* Device firewall/NAT rules are synchronized when UCRM ports are changed in system settings.
* Client can be moved to archive. Then the client can be deleted permanently.

### Fixed
* Skipped next invoicing day fixed
* Redirection to suspend page fixed
* Fixed file permission bug / crashes when unsuccessful write to the cache directory
* Fixed possible problem with PDF generator render
* Fixed validation message in new invoice form
* Date formating on invoice fixed and other minor bugs

## 2.0.8 (2016-07-15)

### Added
* Easy SSL support (Upload certificate files at Settings | Tools | SSL certificate and restart)
* Select boxes for clients now allow searching
* When creating an invoice you can also set up a new tax or product
* Invoiced revenue report PDF export
* Added PDF page size settings (US letter, US legal and A4)
* Additional form fields validations
* Added missing "approve" and "void" buttons for invoices in client's billing section

### Changed
* Admin users now can set their first and last name
* CSV import validation improved
* Better layout for user group permissions
* Invoice form now contains different buttons for "save" and "save and send" instead of checkbox to send email to client

### Fixed
* Fixed problems with deleted services, devices and sites
* Fixed suspend page error "File not found"
* Password reset fixed
* Attaching an invoice to new payment fixed
* Fixed background scripts execution
* Various minor fixes 

## 2.0.7 (2016-07-01)
 
### Added
 * Authorize.Net support for one-time payments
 * Client impersonation feature. As an admin user you can now log in to client zone and see exactly the same what the client can see.
 * Refunds feature. You can create a refund for client upto the amount of client's credit. (not connected to online payment gateways)
 * Custom CSV imports for entities: client, payment. You can upload your custom csv file and match the csv columns with corresponding entity attributes. (Settings | Tools | CSV import)
 * UCRM database backups are created periodically. Backup download and restore feature is enabled. (Settings | Tools | Database backup)
 * Invoices and Payments overview grid can be filtered and exported into pdf
 * Invoice notes for client (visible to client and placed into the invoice) and invoice notes for admin (not visible to client)
 * Personalization of email notifications is enabled using wysiwyg editor (Settings | General | Notifications)
 * You can setup/change port numbers used for UCRM app and UCRM suspend page.
 * Improvements in Tax settings (tax cannot be deleted because of reporting and accountant purposes, it can be replaced globally with new tax though)
 * Database encryption for mailer and device passwords. (Make sure to backup your encryption key, you can find it at /home/ucrm/data/ucrm/data/encryption/crypto.key)
 * Organization based invoice template settings - You can set whether to include tax id and bank account into invoice)
 * User actions are logged now. Actions such as generating invoices, batch actions, logins, etc.
 * You can add manually a custom log entry to each client.

### Changed 
 * Service IP is not validated against router IP ranges (changed to recommendation)
 * Client id is validated to be unique now.
 * Vast performance improvements
 * More user friendly Device interface form
 * Payment entity always comprises currency now
 * Client search should now provide better results
 * Better grid pagination (items per page, control links)
 * Service name now not required and inherited from service plan if not provided
 * Mailer now uses "Sender address" from settings as "Sender" email header and includes "From" field as well
 * Editing "Invoicing from" field on service now possible, if no invoice exists for the service
 * "U CRM Billing" renamed to "UCRM"
 * "Tariffs" renamed to "Service plans"
 * Minor UI changes
 
### Fixed 
 * Sending notifications for overdue invoices is handled properly
 * Service status is reloaded after every change (when suspended or stopped)
 * Fixed password reset for clients and admins
 * Fixed GPS address resolving
 * Fixed duplicate client ID error in new client form
 * Using new user groups with custom permissions works properly now.
 

## 2.0.6 (2016-05-31)
 
### Added
 * Recurring payments - client can set up an automated billing plan based on recurring invoice
 * New billing reports: Taxed amount and Invoiced revenue
 * Search clients using single input for name, phone, email, street or city. This search can even handle typing errors. Additionally, you can search for client by id using this prefix "id:", e.g id:142 will search for client with id 142
 * Late fee can be chosen to be fixed amount or percentage.
 * Fully qualified domain name of the UCRM app has been added to system settings. If provided, it will be used in redirects and email notifications sent to clients
 * Invoice batch printing into pdf using grid filters
 * System log - all user actions are logged now
 * Anonymous statistics
 * 500 Internal Server Error page now contains encoded error message (small grey text at the bottom of page). Please provide the UBNT team with a copy of this text when an error occurs

### Changed 
 * Device information and IPs removed from client zone
 * Now you can add service IP in 3 formats - single IP, range from-to and CIDR format

### Fixed 
 * Suspension postpone redirects to proper port number
 * Overdue invoice notifications are sent correctly
 * Minor UI fixes

## 2.0.5 (2016-05-13)
* Fixed possible file upload problem
* Fixed organization logo and stamp in invoice PDF
* Fixed image thumbnail cache
* Small UI fixes

## 2.0.4 (2016-05-12)
* Fixed PDF generator

## 2.0.3 (2016-05-12)
* Fixed zip package importing in the Setup wizard
* Additional app speed enhancements

## 2.0.2 (2016-05-11)
 
### Added
 * Major app speed enhancement
 * Uninstall script

### Changed 
 * Paid or partially paid invoice can not be edited now, it can be deleted though
 * Installation script improved (does not change postgre password when run more than once) 

### Fixed 
 * Draft bulk approving of recurring invoices fixed
 * Change password feature fixed
 

## 2.0.1 (2016-05-05)

### Fixed
* Sending emails and notifications fixed
* Password fields are no longer visible
* Invoice style sheets fixed
* Tooltips position and other minor UI fixes

### Added
* New feature to test mailer connection and send test email
* Mailer log. All notifications and emails to clients are logged now
* Version of current U CRM Billing displayed on the homepage

### Changed
* Setup of the mailer settings simplified
* Logging into the setup wizard is no longer needed

## 2.0.0 (2016-04-29)

### Manage entities

* Organizations
* Clients
* Tariffs (What internet plan are offered by the organization)
* Client's services (Ordered tariff by a client. Ability to override price, invoicing period etc.)
* Products (other products or one time services offered by the organization)
* Network entities: Sites, Devices, Interfaces
* Admin users, roles, permissions
* Settings (e.g. taxes, currencies, surcharges, default invoicing parameters etc.)

### Billing
* Manual invoicing
* Recurring invoicing at user defined day and time
* Automatic late fees
* Proration of first & last month billed
* Notifications
* Invoice handling
* Batch invoicing
* Invoice printable export into pdf
* Invoice preview (for both manual and recurring invoices)
* Edit/void invoice until paid

### Payments
* Manual payment input
* Gateways integration: PayPal, Stripe
* Payments matching
* Overpayments turning into credit
* Payment in advance - whole payment turns into credit

### Billing & control
* Suspend & late fee & walled garden
* Onetime postpone the suspension by client in order to be able to pay
* Postpone the suspension by admin

### App features
* Setup wizard
* Basic data migration from AirCrm Beta

### Client's site
* Overview of invoices, payments, account balance, contact form, change password
* Payment gateway




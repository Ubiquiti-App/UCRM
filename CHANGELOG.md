# Changelog

## 2.16.0 (2019-05-24)

### Added
*	Terminated services now grayed out on the map overview.
*	The "New Invoice" and "Send invoices with zero balance" toggles are no longer chained.
*	Approve all invoice drafts button added to the drafts grid page.
*	Map client markers improved - it's possible to click on them to go to client/service/site.

### Changed
*	PHP upgraded to version 7.2.18

### Fixed
*	Fixed inability to add items to invoice for some users with specific permissions.
*	Fixed permissions error shown on the client detail page for some users.
*	Fixed missing discount (and other parameters) when a proforma was transformed into invoice.
*	Created date couldn't be modified on new/edit Quote form.
*	Fixed shaping sync after the service's plan is changed via deferred change.
*	Broken page scrolling on some forms.
*	Client zone invitation email is disabled for clients not having username.
*	Minor fixes, UI/UX improvements.

## 2.16.0-beta4 (2019-05-10)

### Added
*	Admins now able to pay via ACH when using the "pay online" feature from admin zone.
*	Improved CC payment form for Authorize.Net and IPPay, new tooltips and look.
*	Custom fonts enabled using CSS, read more in the guide at /help/invoice-templates.
*	Better logging for Authorize.net payments.

### Fixed
*	Fixed payments created as unattached when processing one-time Stripe payments, improved payment matching.
*	Minor fixes, UI/UX improvements.

## 2.16.0-beta3 (2019-04-17)

### Changed
*	Client's address (optional value) is not prefilled automatically in the IPpay online payment form.

### Fixed
*	Fixed "pay total amount" feature in the client zone.
*	Fixed online payments when changing of payment amount was disabled.
*	Fixed back button on the payment success page.
*	UX improvements.
*	Minor Fixes.

## 2.15.2 (2019-04-16)

### Added
*	New option for Stripe subscriptions "Import unattached payments" - if turned on in the organization settings, Stripe payments that would normally be ignored are imported as Unattached payments into UCRM.
*	Added validation for IPpay payment form - zip code length is limited to 10 characters to prevent failing payments.

### Changed
*	Only the full proforma invoice's amount can be paid now, partially paid proforma invoices are not enabled by UCRM.
*	Ticket subject limited to 80 characters. The input longer than 80 characters becomes part of the ticket message (applies only to the input from UCRM Client Zone, not from IMAP ticketing import).
*	PHP upgraded to version 7.2.17

### Fixed
*	Fix issues with ticketing import for emails with incorrect encoding or formatting.
*	Fixed manual editing of client's data usage (manual NetFlow edits).
*	Raw payment amount from Stripe payment now shown in the correct format.
*	Fixed minor rounding issue for predefined amount when creating a new subscription.
*	Fixed performance issues on Organization show and edit pages.
*	Fixed bugs with editing service deferred change.
*	Fixed crashes when batch sending the invitation emails to the client zone.
*	Fixed crash when plugin is updated and its new configuration requires a different configuration type.
*	Minor improvements, tools update, logger improvements.
*	Minor fixes.

## 2.16.0-beta2 (2019-04-01)

### Fixed
*	Minor fixes.
*	Edit modal window fixed for editing service's billing settings.
*	Fixed IPpay subscriptions - trigerring duplicate payments.

## 2.16.0-beta1 (2019-03-29)

### Added
*	2 months period are now enabled for Service Plans.
*	Improved logging of payment subscription errors.
*	Editing of paid invoices or proformas is now enabled. All invoice attributes can be edited except the invoice items.
*	PDF of Invoices and Proforma invoices can be now included in the UCRM backup file. Note that this can increase the backup file size significantly. UCRM can always recreate a missing PDF but the current client's and organization's attributes are used as well as the current invoice template.
*	Better Google Calendar sync of the scheduling jobs. The job's GPS and other attributes (e.g. description, job's tasks) are now pushed to the user's calendar event.
*	Image thumbnails are now available for ticket attachments (supported formats are jpeg, png and gif).
*	Client's custom attributes can be now configured as hidden from the client zone. You can use these attributes for sensitive data or technical data used by API or plugins.
*	Automatic invoicing can be now turned ON/OFF in System > Billing.
*	As an administrator you can create a new online payment on behalf of your client directly from the admin zone (you don't need to log in "as client" to the client zone).
*	Admins without permission to view scheduling are now not included in the scheduling timeline.
*	UI/UX Improvements and minor fixes (e.g. time zone of the system time shown on the dashboard, better invoicing preview when creating a new service).
*	New "pay total amount" button added to the Client Zone, useful for clients having more than one unpaid invoice.
*	"Suspension postpone" button added to the Client Zone. Besides the postponing enabled on the walled garden page, the postponing on the client profile page in the Client Zone can be used.
*	Better UX for the payment subscription window. Clients now get all the info needed before they create a subscription. E.g. (whether the previous invoice is already paid or not and when is the next invoicing day)
*	For plugin developers: now, it's possible to configure plugin's scripts hooked to common plugin actions - for plugin install, update, configure, enable, disable, remove.
*	Plugins with incompatible max version are disabled automatically.
*	Now, you can edit all the service's parameters using a single form. (also for already invoiced services)
*	In-app guide helping WISP migrate UCRM to UNMS (will be enabled when UNMS v1.0 is released).

### Changed
*	Invoice number is not requested now when editing an invoice draft. It is automatically added when the draft is approved.
*	The regenerate invoice PDF button now using the current client's and organization's data (like names, addresses, custom attributes) for recreating a new invoice. Same for quotes or proforma invoices.
*	Changing of period length on service is not enabled to avoid invoicing issues of the given service.

### Fixed
*	Fixed issues with tickets loaded for some IMAP emails in rare formats. 
*	Minor API fixes.

## 2.15.1 (2019-03-28)

### Added
*	Better and more user-friendly password strength validation.
*	New UCRM localizations added: Georgian, Bulgarian.
*	CA certificates are periodically updated.
*	Better plugin installation and backuping/restoring.

### Changed
*	PHP upgraded to version 7.2.16
*	Service period cannot be edited for already invoiced services to prevent possible issues with invoicing.

### Fixed
*	Fixed issues with Stripe subscription payments.
*	UI/UX improvements for google maps.
*	Fixed crashing receipt template in some cases of payments created via API.
*	Factory reset not working, doing no changes to the data.
*	Lets Encrypt TLSv1.0 removed, TLSv1.3 added.
*	Fix for possible issues with ticketing import from some client email replies.
*	Fixed displaying rounding difference on invoices with no custom rounding.
*	Minor API fixes.
*	Minor fixes.

## 2.15.0 (2019-03-07)

### Added
*	UX improvements and more verbose logging of Stripe payments.

### Fixed
*	Fix for FCC report crashes in rare cases.
*	Minor fixes.

## 2.15.0-beta8 (2019-02-28)

### Added
*	New permission "Allow creating payments" available for users with view permission on Payments. This can be granted to cashiers to enable create payments only while disabling edit/delete.

### Changed
*	Plugins: Custom plugin's github URL is no longer required. Useful for custom private plugins or for the dev purposes.

### Fixed
*	Fixed edit of invoices and quotes created prior to the previous beta with more than one invoice item.
*	Minor fixes: incorrect service status displayed in rare cases, UI fixes for IE, and other minor fixes.


## 2.15.0-beta7 (2019-02-22)

### Added
*	Invoices with zero balance amount are always editable now.
*	Now, it's always possible to override the service taxes regardless of the tax config set for the related service plan.
*	Customizable order of the invoice items for all new invoices.
*	Improved UX for the Google calendar sync feature.
*	Improved handling of errors in custom invoice templates.
*	Log of failed email now shows the related client enabling you to jump into the client's profile page.
*	App speed optimizations.

### Changed
*	Proforma invoices are now shown on a new tab separately from regular invoices.
*	PHP upgraded to version 7.2.15

### Fixed
*	Fixed for several API endpoints. GET /ticketing/tickets/activities, GET /proforma-invoice-templates, GET /scheduling/jobs.
*	Fixed credit applying to proforma when creating a new proforma invoice manually.
*	Fixed rare crashes of the Batch Mailing tool.
*	Fixed pushing of amount change for linked payment subscriptions (issues with this appeared only in 2.15-beta branch).
*	Fixed displaying rounding difference on invoices with no custom rounding.
*	Minor API docs fixes.
*	Minor fixes, UX improvements.

## 2.14.8 (2019-02-20)

### Added
*	Improved app performance (for example: faster ticket assignment form).
*	Client Account Number is now obfuscated in the client's log.

### Fixed
*	Terminated services are no longer included in the FCC reporting.
*	Minor fix in the service's billing overview.
*	Improvements for the Data Usage Report, the usage of terminated services is shown properly now.
*	Fixed export button of client's data.
*	Bug fix for /clients/authenticated endpoint.
*	Improved client log export (timestamp instead of date is now attached to the log items).
*	Minor fixes and improvements.

## 2.15.0-beta6 (2019-01-30)

### Added
*	Plugin ID is now available in ucrm.json file for each plugin.

### Fixed
*	Button to apply credit no longer shows on proforma invoices if not applicable.
*	Fixed changing service plan via service's price summary.

## 2.14.7 (2019-01-30)

### Fixed
*	Fixed long PDF generation when containing large overview tables.
*	Minor fixes in CSV payment import.
*	Fixed next month included in invoiced period when it shouldn't in a rare case.

## 2.15.0-beta5 (2019-01-21)

### Added
*	Translations updated - thanks to the community translators.
*	Added invoice.draft_approved webhook event.

### Changed
*	PHP upgraded to version 7.2.14

### Fixed
*	Fixed possible crash on the organization detail page.
*	Export of payment receipt PDF is now correctly ordered based on the order used in the payment grid.
*	Fixed failing API endpoint: GET webhook-event.
*	Fix for automatic payment receipts not being generated for Authorize.net payments and for payments imported via CSV file.
*	Geocoding not automatically triggered in some cases after Client CSV import, additionally, more improvements and validations were added to this feature.
*	Fixed failing manual invoice edit in some rare cases.
*	Fixes and improvements for Proforma invoicing (client zone - processed proforma no longer has "pay online" button, processed proformas are now included in "send unsent invoices" modal)
*	Fixed services being created by changing "Create invoice X days in advance" value in new service form.
*	Fixed long PDF generation when containing large overview tables.
*	Fix invoices sent twice when using "send all unsent invoices" modal as of 2.15.0-beta4.
*	UI/UX improvements.

## 2.14.6 (2019-01-18)

### Added
*	Implemented SHA-512 hash support for Authorize.Net. Signature Key is now required for proper functionality of the Authorize.Net payment gateway as the MD5 hash will be phased out soon.

### Changed
*	PHP upgraded to version 7.1.26

### Fixed
*	UI/UX fixes and improvements.
*	Fixed filtering in client's log export tool.
*	Improved API endpoints for managing client's and invoice's custom attributes.
*	Tickets related to a black-listed email are now properly deleted.
*	Speed up "Invoices Overview PDF" generation.

## 2.14.5 (2019-01-10)

### Fixed
*	Fixed form validation for "created date" in manual invoice form.
*	UX Optimization - slow ticket view and failing ticketing assignments in case UCRM contains a huge number of clients.

## 2.15.0-beta4 (2019-01-08)

### Fixed
*	No "new invoice" email notification generated for automatic invoicing. (All unsent invoices can be sent manually though - using the batch emailing for all unsent invoices)
*	Fixed batch emailing of a large amount of unsent invoices.
*	Fixed resending of a large amount of failed emails in "Resend failed emails since" dialog.
*	Other minor fixes.

## 2.15.0-beta3 (2019-01-04)

### Added
*	Payment methods filter for payment grid is simplified, unused items are hidden now.
*	Improved client's address validation when PayPal subscription is being created.
*	UX improvements and fixes for Client CSV batch import.
*	API - Added two attributes to Clients endpoint related to proforma invoicing.
*	PHP Soap enabled for UCRM Plugins.

### Changed
*	NetFlow Auto-setup feature has been removed, the NetFlow config can now only be set manually using the how-to guide which has been added.

### Fixed
*	Fixed "Separate invoicing" toggle couldn't be switched off in service's billing options.
*	Fixed issues with "failed emails batch resend" when a huge amount of emails were to be resent.
*	Fix for client's account statement. Today's items were not visible when UCRM was used in some specific time zones.
*	UI/UX fixes and improvements.

## 2.14.4 (2019-01-04)

### Fixed
*	Client's Custom ID autoincrement fixed.
*	Fixed crashes when enabling Let's Encrypt certificate.
*	Fix for UCRM creating multiple invoices for a single service's prorated period in some rare cases.
*	Now it's possible to create a new invoice more than 30 days in advance (before the period start).
*	Invoices having the same number are renumbered in UCRM, prefix D01_, D02_ etc. is added to such invoices which could have been created in older UCRM versions. Invoice PDFs are not affected by this fix.
*	Fixed possible problem with PayPal subscriptions.
*	Fixed issues with manual update script.
*	UI/UX fixes and improvements.

## 2.15.0-beta2 (2018-12-20)

### Fixed
*	Fixed search in the client grid.
*	Fixed failing payment grid ordering by username.
*	Fixed crash when adding payment linked to 2 or more proforma invoices.
*	Fixed wrong auto-updates of service GPS when user edits the service.
*	Help guide for Proforma invoicing is now indexed by the quick search tool.
*	Minor fixes, UI improvements.

## 2.14.3 (2018-12-20)

### Fixed
*	Fixed crashes on some pages when no client or no lead exists yet. (scheduling agenda page, quotes page).
*	Client CSV file (created as client grid export) can be imported back to UCRM without no issues now.
*	Fix for NetFlow data collector, the data records are no longer pruned after 100 days.
*	Fixed issues with FCC reporting. Some client's addresses which couldn't be geocoded were not shown in the resulting "error file".
*	Minor fixes and improvements, speed improvements of some pages and modal windows.

## 2.15.0-beta1 (2018-12-18)

### Added

#### Major Improvements
*	Pro-forma invoice. Feel free to send pro-forma invoices (for example as a "payment notice") instead of real invoices to your clients. The regular invoices will be generated automatically (in the paid status), once the pro-forma invoice gets paid.
*	New simplified forms for Client, Service, and Service Plan.
*	Easy plugin installation. View all available plugins inside the UCRM app, download and install any using a single click.

#### Improvements for Billing
*	Customizable rounding of invoice total. For example, this may be used if you don't want to charge cents to your clients. Set it up in System > Organizations > edit your organization's billing options.
*	Payment receipts can be numbered using a custom sequence (similarly to invoice numbering). If you want to show the number on recept PDF, go to System > Customization > Receipts and put the number placeholder to the template.
*	Configure how to display client's credit/debit balance (positive or negative sign can be used for client's credit, the opposite sign will be used in case of client's debit). Go to System > Settings > Application.

#### Other new features
*	Improved CSV Import. Now you can import thousands of clients (and their services) using a single CSV file. Additionally, GPS coordinates are automatically computed from the client's address.
*	Tickets having subject only are enabled now (the ticket body can be left empty).
*	Job's attachments are now included in UCRM backups.
*	Payment list now contains the name of the user who added the payment into the system.
*	More options for the Sandbox Termination. Now, you can choose whether the invoicing should continue or start over when you delete all the invoices during the sandbox termination.
*	Variable for "Invoice amount due" is now available in the "New Invoice Email" template.
*	UI/UX Improvements: "Super admin" visibly marked in the user list, more tooltips and improvements enhancing intuitive usage, better customization of invoice/quote/proforma number sequence.
*	Now, a closed ticket is reopened automatically when the client adds a comment to the ticket.
*	Placeholder for "Taxable supply date" is now available for invoice templates.
*	Better default Client Zone invitation email text, client's username is now included. If you are using customized text, you can add the username placeholder on your own.
*	API Enhancements: payment ordering and filtering enabled; client's and invoice's custom attributes editable; new API endpoints to void, delete invoice and to download invoice PDF; New option to create a quoted service; New "apply credit" option while creating invoice via API, true by default.
*	Webhooks triggered by "delete actions" are now sending the deleted entity, instead of just the id. Better json formating in webhook logs.
*	CSS for custom UCRM look is included in the backup file now.
*	Client's log improvements.

### Changed
*	UX Improvements in the main menu structure. Invoices and Payments are now easily accessible. Some more useful features are more accessible now, e.g. the Batch Mailing tool button above the clients grid.
*	Now, the internal ticketing notifications (to the support email address) are sent even when the comment or ticket is created by an administrator (and not only by a client).
*	EULA and Privacy Policy moved from the login screen to avoid confusions among WISP's clients.
*	Global settings option "Approve invoices automatically" is now applied to all existing client's services, not only to the newly created ones. This is applied only to services having "Approve invoices automatically" set to "use system default".
*	The dashboard overview now comprises all organizations.
*	PHP upgraded to version 7.2.13

### Fixed
*	Account statements now include today's activities.
*	Fixes and improvements related to the webhooks for ticketing.
*	Crashes of Client Zone invitation emails when sent in a batch to a big number of clients.
*	Fixed period invoicing suppressed till the next auto-create process in the situation, when "prorated separately" option is used. Now, both the prorated and the following period are invoiced separately, though at the same time, as they should.
*	Fix for Office365 shared email accounts linked for IMAP Ticketing.
*	Minor fixes and improvements.

## 2.14.2 (2018-12-12)

### Changed
*	TLS 1.0 no longer supported by UCRM web server.
*	Server domain name is automatically lowercased from now on, to prevent various issues with SSL certificates.
*	PHP updated to version 7.1.25.

### Fixed
*	Account statements now correctly contain today's invoices and payments.
*	Drag and drop of service's map pin was broken for leaflet (mapbox) maps.
*	Fixed issues with deactivating and deleting plugins.
*	Fixed failing backup file creation in case there are malformed plugin files.
*	Fixed missing "data/config.json" file for plugins with only optional parameters.
*	Fixed failing issuing of invoices due to duplicate invoice number.
*	Client filters now include client leads in Scheduling Agenda and Quote lists.
*	Fixed some receipt template placeholders.
*	Minor bug fixes in GET Device API endpoint.
*	Fixed issues with device sync.
*	Minor fixes, UI/UX improvements, in-app guides and translation updates.

## 2.14.1 (2018-11-26)

### Fixed
*	Missing placeholders for client's custom attributes are now shown and can be added to the invoice template and account statement template.
*	Online payment for remaining amount of partially paid invoice is now enabled in the Client Zone, even when "Payment amount change" is not allowed (in System > Settings > Client zone).
*	Client's attribute "isArchived" now available through API, apiary docs updated.
*	Webhook for "service edit" action is now triggered correctly.
*	Fixed new invoice form crashes while the automatic invoicing is being processed in the background.
*	Fixed crashes caused by missing plugin files in case plugin was extending UCRM menu.
*	Improved new UCRM release notifications. You can now choose between stable and beta channels (in System > Tools > Updates) and if you are on beta channel you will always get notified about the newest available release.
*	Better Dropbox error handling and logging.
*	Fixed issues with MercadoPago online payments.
*	Fixed failing sync with several device types.
*	Minor fixes.

## 2.14.0 (2018-11-15)
Incorporates all new features and fixes from 2.14.0-beta1 up to 2.14.0-beta4

## 2.14.0-beta4 (2018-11-15)

### Added
*	UCRM Plugins can now contain a whole public directory, whose content is publically accessible. Read more at https://github.com/Ubiquiti-App/UCRM-plugins/blob/master/docs/file-structure.md

### Changed
*	"Subscriptions" renamed to "Payment Subscriptions" to avoid frequent confusions.
*	PHP updated to version 7.1.24.

### Fixed
*	Fixed job IDs always being null in API endpoints.
*	Fixed possible issues with invoice PDF rendering.
*	NetFlow chart is properly hidden now when no NetFlow data are available.
*	Fixed crash on service detail in case the service has some taxes.
*	Job's attachments are properly deleted from the filesystem when the job is deleted.
*	Better UI of webhook log formatting.
*	Improved UCRM update process.
*	Minor fixes.

## 2.14.0-beta3 (2018-11-09)

### Added
*	Pagination enabled for more API endpoints (use offset and limit parameters).

### Fixed
*	Crashes of client service page due to malformed GPS coordinates.
*	Webhook improvements and fixes. New events added: job add, edit and delete event, "ticket changed status" event fixed, fixed duplicate ticket add event on IMAP import.
*	Better prevention from duplicate invoice numbers which could appear in case of simultaneous manual and automatic invoicing.
*	Fixed uploading of backup file in the UCRM initial wizard.
*	Plugins dev improvements and fixes: Parameter "pluginPublicUrl" is now correctly set in plugin config file automatically. Besides, ucrmLocalUrl is also generated to the plugin's config now. It can be used instead of the public URL.
*	New API endpoint to trigger address geolocation of the client and client's service: PATCH /clients/{id}/geocode; PATCH /clients/services/{id}/geocode.
*	Fixed user grid in System > Security > Users.
*	"Ticket changed status" email notification not working.
*	Minor improvements and fixes.

## 2.13.6 (2018-11-07)

### Added
*	UI, UX improvements: ZIP code shown after State (for USA and Canada).
*	Uncollectible invoices hidden from Client's profile page (the same way they are hidden from the dashboard).

### Fixed 
*	Stripe payment - rounding error fixed.
*	Crashes while creating a new invoice in some rare cases.
*	Invoice grid filter "Send by post" working properly now (even for clients having the system default value set for this option).
*	Fixed "Select all" button not selecting all grid items, only the items on the current page.
*	Search fields optimized for mobile view.
*	Minor bug fixes.

## 2.14.0-beta2 (2018-10-23)

### Added
*	API endpoints enhancements (more parameters and filters for getting invoices, invoice items, clients and services).
*	UCRM Backup file of any size can be uploaded and restored.
*	CSS hint added to the Invoice template for an easy adjustment of the invoice PDF margins.
*	Translations updated

### Fixed
*	Fixed removing a ticketing group from a ticket.
*	Webhooks linked to UCRM Plugins are now using "localhost" instead of UCRM Public URL. Additionally, SSL cert verification can be turned off, which enables you to use self-signed certificates.
*	Minor bug fixes.

## 2.13.5 (2018-10-23)

### Added
*	API Improvements, new client archive/delete endpoints, pagination added to get clients endpoint.
*	API documentation updated.

### Changed
*	PHP updated to version 7.1.23.

### Fixed
*	Precautions for MercadoPago payments to ensure a new payment is received regardless of incorrect behavior of MercadoPago server.
*	Failing organization edit form in some cases.
*	Fixed reactivation of suspension caused by an unpaid invoice.
*	UI fix: amount paid properly updated when creating a new invoice with "use credit" flag
*	Minor bug fixes.

## 2.14.0-beta1 (2018-10-05)

### Added

#### Main Improvements
*	AirLink integrated to UCRM. For an easier survey of the link between a client lead and the nearest Site.
*	API Improvements, this can be managed with API now: client's password, contacts and tags, job's tasks, ticket's jobs, FCC block ID, last invoiced data and data usage of client's services, pagination added to get clients endpoint, new client archive/delete endpoints, etc.
*	Mobile view improved, UCRM admin zone can be used on mobile phones now.
*	Improved Sandbox termination giving user more control of which data to keep and which data to drop.
*	Accessibility improvements, many forms usable with keyboard only and other UX improvements.
*	Brute force protection for 2FA.

#### Plugins, API, Webhooks	
*	New UCRM Plugin integrating SMS gateway.
*	Plugins boosted. Now, the plugins can be used to create a new in-app page accessible only for logged users. It can be used for custom reporting, data exports, etc.
*	Now, you can associate any UCRM Plugin with any UCRM webhook more easily.
*	Webhooks improvements - you can set a different webhook URL for each action now. This extends the possibilities of hooked scripts and plugins.

#### Other Improvements
*	Increased password strength requirements.
*	Improved Client CSV batch import. Now, you can set client's username, GPS coordinates, client's taxes or service's taxes. See the CSV samples suitable for USA or Europe.
*	New placeholders enabled for the suspension notification template: service Active From and Active To date.
*	More placeholders added to several email templates, enabling to paste various organization related attributes.
*	More formatting options for email templates, check out the placeholder variables and their formatting in System > Customization > Email Templates and Invoice Templates.
*	UX improvements, better validations, better error messages improved with links to system settings.
*	Better UX for creating a new canned response from existing ticket reply.
*	App speed improvements.

### Fixed
*	Minor fixes and UI improvements.
*	Postpone suspension link might redirected client to pay the oldest invoice, now it redirects to the invoice that triggered the suspension.
*	Fixed Elasticsearch not working for more than 10 000 items.

## 2.13.4 (2018-10-03)

### Fixed
*	Fixed possible duplicate payments from PayPal and Stripe which could have been created in some rare cases.
*	API security fix. After removing API key, a previously authenticated API user was able to continue using API until the session expired.
*	Fixed client's API endpoints. Now, client leads are included, leads can be recognized and filtered by isLead attribute.
*	Missing attributes added to API docs.
*	Fixed Client CSV import issues when the CSV contains 0% tax.
*	Fixed possibly failing payment delete and client action.
*	Fixed surcharge quantity calculation in invoice preview in the New Service form.
*	UI fixes.

### Changed
*	Elasticsearch index is created after UCRM boot which is completed faster now.

## 2.13.3 (2018-09-26)

### Fixed
*	Fixed UI in plugin configuration.
*	Fixed failing subscription creation.

## 2.13.2 (2018-09-25)

### Added
*	"Go to Client Zone" button on the Payment Page shown only for clients having access to the Client Zone.
*	API extensions comprising Client Leads.

### Changed
*	PHP updated to version 7.1.22.

### Fixed
*	Top Downloaders/Uploaders view contains manual data-usage changes now.
*	Fixed service reactivation crashes.
*	Proper client's credit shown when creating a new refund.
*	Fixed FCC geocoder crash in some rare cases.
*	Fixed possible issues with PayPal payments.
*	Client Leads now supported by UCRM mobile app.
*	Fixed possible issues with Stripe ACH subscriptions.
*	Minor fix in user's permission check.
*	UX Fixes and improvements.

## 2.13.1 (2018-09-11)

### Added
*	New placeholder "Online Payment Link" enabled in the Invoice PDF template. Similarly to the "new invoice email" placeholder introduced in 2.13.0 this can be used for a direct redirection to the payment page with no need to log in to the client zone.

### Fixed
*	Frozen client edit page caused by Geocoding API being disabled in the user's Google account. UCRM can now prevent the page from being frozen in this case.
*	Payment ID placeholder not working in the payment receipt template.
*	Better PayPal validation errors and unsupported currency error. Additionally, these currencies are now supported in UCRM PayPal integration: HUF, JPY, TWD.
*	Fixed error when editing client's data usage manually.
*	Minor fixes, improved validations.

## 2.13.0 (2018-08-30)

## 2.13.0-beta4 (2018-08-30)

### Changed
*	The default Suspension delay and Late fee delay is set to 1 day (for new UCRM installations only) because when 0 is used, the suspension and late fee is triggered on the due date of an unpaid invoice.
*	PHP updated to version 7.1.21.

### Fixed
*	Fixed Indian rupee symbol.
*	Fixed job drag&drop in the scheduling timeline.

## 2.13.0-beta3 (2018-08-22)

### Added
*	Clients CSV import improvements: address is no longer required, a better overview of invalid records, support for importing thousands of records.
*	Network map optimization - when zoomed out, multiple clients in the immediate vicinity are clustered using a single marker. Links between clusters and Network Sites are not rendered - for MapBox maps.
*	New system status checks for invalid templates for invoices and receipts.
*	New VES currency (Bs.S.) added.

### Changed
*	Commenting and job assigning is now enabled for closed tickets.

### Fixed
*	Fixed memory issues and performance for generating thousands of invoices.
*	Fixed possible failures when deleting or voiding multiple invoices.
*	Fixed possible failures when deleting multiple tickets.
*	Fixed resending of emails having an attachment.
*	Account statement tab hidden for non-superadmins even when they have proper permissions.
*	Fixed service validation in service edit form.
*	Minor fixes, UX improvements, app speed improvements.

## 2.12.4 (2018-08-17)

### Changed
*	During the Client CSV import, the first client's email is always marked with Billing and General tag and it's also used as the client's username for the client zone (if not already in use by another client).

### Fixed
*	Fixed compatibility with new Stripe API version (2018-07-27).
*	Fixed issues with reset password feature (password reset token is now deleted after expired or after used; user is no longer logged in automatically after password reset, this fixes bypassing 2FA).
*	Fixed linked Stripe subscription being removed or changed incorrectly when related service was changed.
*	Fixed issues with taxes on invoice. It was not possible to remove all taxes from an invoice item while manually editing an existing invoice; taxes not automatically applied when adding invoice item for manual invoicing.
*	Preventing from crashes when sending a payment receipt when the custom receipt template is corrupted.
*	Fixed failing client delete action in case some client's email has been resent to them.
*	Fixed possible crashes of Network > Device view page.
*	Minor fixes.

## 2.12.3 (2018-08-08)

### Fixed
*	Fixed IMAP ticket loader for emails coming from Office 365.
*	"Linked subscription" now visible in the Client Zone.
*	These email placeholders were empty for business customers: %CLIENT_FIRST_NAME% and %CLIENT_LAST_NAME% Now, company contact person's first name and last name are used for these placeholders.
*	Fixed failing IPpay subscription creating in some rare cases.
*	Minor fixes.

## 2.13.0-beta2 (2018-08-06)

### Changed
*	Network map optimization - when zoomed out, multiple clients in the immediate vicinity are clustered using a single marker. Links between clusters and Network Sites are not rendered in Google maps from now.

### Fixed
*	Fixed failures of "Multiple payment form".
*	Fixed Initial and Final Balance in the Account Statement view - wrong values in some cases.
*	Fixed error 500 in client edit form, when a new contact type is added.
*	Fixed possible failures of NetFlow data chart.
*	Fixed failures of payment subscription creating for Authorize.Net, MercadoPago, PayPal.
*	UX improvements and minor fixes - better URLs in notification preview, fixed validation of Clients CSV Import, UI fixes in Ticketing section, Fixed sorting of Backup files list.

## 2.13.0-beta1 (2018-07-30)

### Added
*	Client Leads - potential clients are now shown separately from active clients. Add leads individually, import leads as CSV or via API (from a custom online sign-up form). Invoicing for a lead is inactive until you the lead is turned into an active client (manually or by adding a regular service). Leads are also visible on the Network map.
*	Paying online is now easier for your clients – accessible even without logging in. Just add this link into your invoice email template: <a href="%ONLINE_PAYMENT_LINK%">Pay online</a> (Go to System → Customization → Email Templates and paste the link there.)
*	Account statements were added – view (or export) client's account statement to understand balance changes in time. (Also visible in Client Zone.)
*	Improved Import of payments – CSV imports from banks or other systems are now simpler and faster. And clients can be matched by Custom client IDs or Custom attributes.
*	We added Top Uploaders to the Dashboard and improved these charts.
*	Now, you can create a new job directly from the ticket screen.
*	Plugin enhancements - now, you can define types of plugin parameters, e.g. checkbox, datetime, choice, file, textarea.
*	New: When you use the batch sending of unsent invoices, you can mark some invoices as "already sent" so they won't be shown in the list any more.
*	New feature: hide failed email warnings from the dashboard notification box. Once you solve an unsent email, you can hide this warning.
*	New permission for Client's financial information. Now configurable separately from permission for global financial info on the dashboard.
*	HTTP 2.0 supported and other app speed improvements.
*	Nice looking maintenance page when UCRM update is running.
*	More details included in the export of client's log entries into CSV file.
*	Better UX for UCRM backups. The backup file name can now contain a custom prefix.
*	Page size of the client log box is configurable now.
*	New currencies added: AED, BIF, CDF, CVE, DJF, ETB, GEL, GHS, GMD, GNF, HTG, KMF, LSL, MDL, MGA, MMK, MOP, MVR, MWK, RWF, TJS, TOP, UGX, VEB, WST, XPF, ZMW
*	Better UX for new client form - "save and send invitation" button is disabled in case the client has no email address.
*	Send invoices improvement - unsent invoices can be marked as already sent if you don't want to see them again in the send dialog.
*	Updated Google maps API guide.
*	UX Improvement - deactivated administrators are hidden in all select-boxes and in the Scheduling view. Log entries are not affected by user deactivation.
*	UX improvements, minor fixes.

### Changed
*	Obsolete services (after a deferred change or after reactivation) will no longer bother you in the new invoice form while creating a new invoice manually.
*	Clients can now only add a bank account in the Client Zone if you have enabled Stripe ACH feature.

### Fixed
*	Zero-decimal currencies are now handled correctly for Stripe.

## 2.12.2 (2018-07-30)

### Changed
*	PHP updated to version 7.1.20.

### Fixed
*	Fixed grid sorting in Custom Attributes configuration in System Settings.
*	Fixed submitting an empty message in Client Zone support form crashing UCRM (in case Ticketing is turned off)
*	Fixed some cases, where suspension synchronization was triggered even though it was not needed.
*	Fixed surcharges disappearing on old invoices, when service was changed by deferred change feature.
*	Fixed behavior of mailer AntiFlood.
*	Fixed minor bug in job form - wrong autocomplete of GPS, address fields.
*	Possible fix for mailer failing with: Expected response code 250 but got code ""
*	Fixed import of tickets missing "udate" header.
*	Failing PayPal subscription creating/cancellation due to PayPal BC changes.
*	Minor fixes.

## 2.12.1 (2018-07-13)

### Added
*	New feature: regenerate PDF for Quote (similar to regenerate invoice PDF feature).
*	Street or satellite view remembered by the system.

### Fixed
*	Invoice/Quote PDF files were overwritten when multiple organizations are configured with the same invoice/quote numbering.
*	Fixed NetFlow data disappearing after deferred change or reactivation of a service.
*	Fixed filter for Batch Emailing - clients with no services were not included.
*	Fixed minor permission issue - client search could be used even without permissions to view clients. Client profile was correctly inaccessible though.
*	Only one email address is now allowed in all "email address" fields. Previously more addresses could be filled in, but mailer crashed on it.
*	Fixed duplicate header notifications about new ticket comment.
*	Better error message in case resending email fails.
*	CSS for all email notifications fixed for MS Outlook.
*	Fixed modal close in Safari.
*	Minor fixes and UX improvements.

## 2.12.0 (2018-07-03)

### Fixed
*	Fixed invoicing issues for services having a deferred change set for the future.
*	Service surcharge invoice item not visible on invoice in some rare cases (related to the last invoice created before deferred service change is applied). The invoice total balance is not affected though.
*	Minor fixes.

## 2.12.0-beta4 (2018-06-29)

### Added 
*	Improved application performance.
*	UI, UX Improvements for CSV import of clients & services. Additionally, client's note (description) can be imported now as well.
*	New header notification after successful UCRM update with a link to the changelog.
*	Archiving/Deleting a batch of clients is now processed in the background.
*	Translations updated.

### Changed
*	Changes in the first run wizard, demo mode is turned on by default.
*	PHP updated to version 7.1.19.

### Fixed
*	Online payment now available again for logged out clients (after suspension postponing or service reactivation).
*	Fixed failing logging out from client zone.
*	Plugins are now executed in their own directory.
*	Prevention from "Chrome save password popup" while creating a new ticket.
*	Minor fixes and improvements.

## 2.12.0-beta3 (2018-06-21)

### Added 
*	Russian localization added.
*	UI improvements for Client import.

### Fixed
*	Fixed ticketing crash in Client Zone in case client had more than 10 tickets.
*	Minor fixes.

## 2.11.3 (2018-06-21)

### Fixed
*	Failing batch invoicing. Automatic invoicing and manual batch invoicing button may not be working in some cases.
*	Missing button for cancel subscription in some cases.
*	Fixed EdgeRouter™ PRO connection issues.
*	Failing QoS configuration on ER v1.10.
*	Fixed possible errors with batch deleting of archived clients.
*	Fixed crashes when client uses browser back button to modify just created IPpay subscriptions.
*	Fixed Authorize.Net subscription start date moved 1 day backwards in some cases.
*	Fixed crash in client's ticketing section in some rare cases.
*	District of Columbia missing in the list of states.
*	Fixed failing batch emailing.
*	Other minor fixes.

### Changed
*	UCRM error reporting form is now displayed only to admins, never in the client zone.

## 2.12.0-beta2 (2018-06-11)

### Added
*	Improved CSV import enabling you to create clients along with their services in a single batch. See the sample CSV file in System > Tools > Client import.
*	Quotes are now shown in the Client Zone.
*	UCRM plugins are now included in the UCRM backup file.
*	Bach payments improvements, UI fixes, and better validations.
*	Batch invoice sending improvements, UI upgrade.
*	Improved configuration of UCRM backup sync on Dropbox.
*	Downloaded ticket attachments are now included in the UCRM backup file. If you delete downloaded attachment from UCRM, it will not be included, but can still be downloaded from the IMAP inbox.

### Changed
*	Symfony updated to 3.4.11.

### Fixed
*	Some tickets not visible in the list in some cases when there are many tickets in the list already (both for the global ticket list and client's ticket list).
*	Empty invoices or invoice drafts being created automatically for clients and services not eligible for invoicing, in some cases.
*	Permissions of non-admin groups for newly added UCRM features, after UCRM is upgraded, were shown as "view" while they were actually "denied" in System > Security section. Now, it's shown as denied properly.
*	Minor bug fixes, UI improvements and tooltips.
*	Fixes in apiary docs.

## 2.11.2 (2018-06-06)

### Fixed
*	Empty invoice or invoice drafts being created automatically for clients and services not eligible for invoicing, in some cases.
*	Late fees issued and suspension applied at a wrong time (in UTC instead of the local time zone).
*	IMAP Import stopped working in some rare cases due to invalid attachment's filename or mime type.
*	Fixed issues with Billing > Refunds view.
*	Minor fixes.

### Changed
*	PHP updated to version 7.1.18.

## 2.12.0-beta1 (2018-05-28)

### Added
#### New Features
*	Batch payments insertion. You can add multiple payments for several clients in a batch using a single form.
*	Batch resend of failed emails. You can resend all failed emails in a batch from a specified date.
*	Recreate Invoice PDF feature. Once the invoice PDF is created, it's not modified automatically. If you need to update the PDF manually, you can do so now. For example, it may be useful when you apply client's credit to already created invoice and you want to update the balance due on the invoice.
*	You can find any option in the UCRM Settings using the header search bar.
*	Recently failed emails shown in the dashboard now. Whenever an email failed to be sent from UCRM due to any reason, you will know it and you will be able to resend all of them in a batch.
*	You can define the localization for organization's currency to control the currency format and code/sign.
*	"2FA enabled" option visible in UCRM user grid.
*	Data usage table added to the Client Zone.
*	Improved system logs. More system log entries for IMAP import feature and for subscription canceling, some unimportant log messages are omitted.
*	Now, in the data usage report, you can click on the client to jump directly to the client's profile or service page to view more details about the client's NetFlow data.
*	New "Quantity (rounded)" invoice template placeholder and new allowed methods round and number_format. Use this to control the decimal places shown on invoice item if you don't like the default unrounded quantity values. This may be useful for prorated periods.
*	Improved payment receipt default template with more placeholders showing details about online payment and subscription.
#### Ticketing upgrades	
*	Linking tickets and jobs. You can link ticket(s) with job(s) to monitor and schedule a job related to some client's tickets.
*	UI upgrade for Ticketing section.
*	As an administrator, when you click on ticket in client's email notification, you are now redirected to admin zone, instead of the client zone. (On condition, you are logged in)
*	Now, you can modify the starting date of tickets import from IMAP inbox.
*	Ticket attachments coming from IMAP email are stored in UCRM from now. You can define the maximum file size allowed.
*	IMAP Import can be temporarily disabled now. You can use the turn on/off toggle.
*	"Reply-to" header is now used for incoming ticket email processing. When used, it takes precedence over the From header attribute.
*	Now, ticket creation timestamp is copied from the IMAP email received timestamp making the order of UCRM tickets more user friendly.
#### API improvements	
*	Now, you can get the list of all currencies in UCRM, set users/client avatar color.
*	Added emailFromAddress and emailFromName to ticket and comments API endpoints to enable you to create tickets in the same way IMAP import does.
*	Better docs and minor fixes.
*	New API endpoints and enhancements. Now, you can manage client's invitation email to the Client Zone, refunds or service plan's data usage limit through API.

### Changed
*	Now, you can turn off the invoicing emails for a client by removing the "billing" tag from all the client's contacts. Previously, invoicing emails were sent to all the client's contacts in this case but this fallback feature has been removed.

### Fixed
*	When credit is being applied automatically to invoices, it is shown properly in the invoice preview now.

## 2.11.1 (2018-05-28)

### Fixed
*	Client data from Stripe and Authorize.Net are now deleted automatically as soon as the subscription or client is deleted in UCRM. This must be deleted manually from the Stripe or Authorize.Net dashboard for subscriptions/clients deleted in v2.11.0 and prior.
*	Fixed "prorated separately" option for service invoicing. First prorated period was always invoiced separately in case of forward invoicing.
*	Tax report fixes related to "tax inclusive pricing".
*	Fixed possible issues with client edit form.
*	Fixed ticket order for API and mobile app.
*	Fixed service IP change not logged.
*	Fixed elastic index building for network devices.
*	Minor fixes for API related to payments and refunds.
*	Minor fixes and UI/UX improvements.

## 2.11.0 (2018-05-18)

### Changed
*	Client is now redirected to pay for the oldest unpaid invoice instead of newest in the walled-garden page after postponing the suspension.
*	Late fees are now always generated at the same time every day, i.e. soon after midnight. Before, some fees could have been generated later that day due to manually created invoices.

### Fixed
*	Fixed rare crashes when editing client services.
*	Fixed crash when creating new client in case no default organization was selected.
*	Elasticsearch now does not cause crashes when index cannot be updated. This happened for example when there was not enough disk space left and indexes were automatically switched to read-only mode.

## 2.11.0-beta5 (2018-05-17)

### Changed
*	Organization currency cannot be changed and client's organization cannot be changed to another organization having different currency when some financial data exist (e.g. invoices, payments) to prevent from inconsistent data.

### Fixed
*	Failing configuration page for payment receipt templates when other than USD currency is used on default organization.
*	These invoice template placeholders were fixed: Account balance, Account credit, Account outstanding. Now, these placeholders contain the current invoice's due balance.
*	Fixed permanent delete crash, when the client has subscription that can't be canceled (for multi-delete from client grid view only).
*	Fixed issues with MercadoPago payments.
*	Fixed plugin exception handling in several cases, e.g. failing UCRM boot due to a corrupted plugin.
*	Fixed possible issues with the factory reset of UCRM demo mode.
*	Improved speed of IMAP ticket importing.
*	Fixed ticket import for IMAP emails having an empty body.
*	Fixed "show email original" for tickets coming from some IMAP servers.
*	Fixed header notifications for new tickets or ticket comments.

## 2.11.0-beta4 (2018-05-10)

### Added
*	Improved database performance.
*	New tax summary placeholders. Added to the default invoice template in case tax inclusive pricing mode is on.
*	API enhancement. Now, you can get Device Interfaces with their IPs.
*	Improved troubleshooting guide with SMTP issues in cloud-hosted UCRM.

### Changed
*	PHP updated to version 7.1.17.

### Fixed
*	Fixes and validations for Payment CSV import.
*	Fixed failing batch and manual invoice generating in some cases.
*	Now, all services get suspended at the same time, i.e. soon after midnight. Before, some services could have been suspended later that day due to manually created invoices, which became overdue.
*	Fixed broken chars in email subjects in some cases.
*	Fixed deleting of a payment receipt template.
*	Fixed possible issues with the factory reset during the Demo Mode termination.
*	Minor fixes and improvements.

## 2.10.2 (2018-05-04)

### Fixed
*	"Amount Paid" on invoice preview is now shown as a positive number, same as it is shown in invoice PDF.
*	Fixed wrong URL generated for notification and emails in case a custom HTTPS port is used.
*	Fixed tax report not containing all invoices whose created date didn't belong to specified date range due to UCRM time zone.
*	Added support for CORS, fixing API error 405.
*	Fixed issues with plugin update.
*	Minor fixes and UI/UX improvements.

## 2.11.0-beta3 (2018-04-24)

### Added
*	Italian localization added.

### Fixed
*	Fixed possible problems with IMAP ticket import after the IMAP configuration is changed.
*	Nginx server updated to the latest version, fixing the error 502 occurring on several places incidentally.
*	Minor UI fixes.

## 2.11.0-beta2 (2018-04-13)

### Added
*	Extensions for customizable templates. You can show billing period type (e.g. "backward", "forward") and show and modify dates (e.g. Invoice Due Date + 2 days).

### Changed
*	Tickets based on blacklisted emails are pruned but tickets associated with clients are excluded from this pruning now.

### Fixed
*	Fixed occasional image loading failures for invoices, login page, etc
*	Fixed UCRM upgrade failures in case Elastica failed to start.

## 2.10.1 (2018-04-13)

### Added
*	Now, you can allow mail servers with self-signed certificate.

### Fixed
*	Fixed pruning of old UCRM backup files.
*	Fixed UI responsivity for Ticketing section in the Client Zone.
*	Fixed permanent deleting of a client having a payment subscription.
*	Several minor fixes and improvements.

## 2.11.0-beta1 (2018-04-05)

### Added
*	New "Linked Subscriptions" for Stripe. You or your client can create new subscription which always reflects any price change of the linked service. E.g. when a tax, surcharge or discount is added or modified, the new service price will be charged next time automatically.
*	Customizable subpages for the Client zone. You can add and configure a custom subpage accessible by the clients while logged in the Client zone.
*	Improvements for FCC reports. Configurable service type and Maximum Contractual Bandwidth per each service plan.
*	Payment receipt templates. Configurable template of the payment receipt which can be used both for email and PDF.
*	Customizable invoice attributes and placeholders. You can define custom attributes for each invoice, and include this into the invoice template. Using API/Plugins/Webhooks you can include any data from any 3rd party service (e.g. AFIP invoice codes needed in Argentina)
*	Configurable email blacklist for automatic Ticket imports from IMAP server.
*	Added an option to show / hide service shaping information (download / upload speed) in Client Zone.
*	Added "Printed" filter to invoice lists.
*	PDF preview now easily available for each invoice or quote.
*	Option to enable/disable online payment amount change by client. Until now, clients can modify the payment amount, you can disable this.
*	Manually canceled suspension (related to past due invoices) can be restored manually again.
*	The next client ID value can be increased, during the application first run (in the app wizard) and even later when some clients already exist (in System > Settings)
*	UX/UI Improvements (e.q. client's address automatically set when creating a new job, better tooltips, and warnings, etc.)
*	Better UX for editing service. You can easily modify the price, period or service plan of any client's service. Click the edit button at "Invoice information" box.
*	Now, you can view and delete any webroot file, uploaded in System > Tools > Webroot.
*	Improved self-service Reactivation / Prepaid mode. Clients can set the length of reactivated service, they can prepay the specified number of billing periods.
*	More placeholders available in customizable twig templates.
*	Improved API responses. The new or edited entity is now included in the response content body.
*	Improved mailer settings of Support email address and System notification address.
*	Client log filter configuration is now remembered.
*	Invoice API improvement - service invoice items now contain invoiced date period in item label.
*	Dropbox sync improvements.
*	Webhooks improvements.

### Changed
*	Improvements for FCC geocoding - codes are now geocoded automatically in the background, better handling of failed addresses.
*	PHP updated to version 7.1.16.

### Fixed
*	Fixes and improvements of Ticketing IMAP emails importing.
*	NetFlow not monitoring upload in some cases when the suspension DNAT rules are enabled on the router.
*	Fixed pruning of old UCRM backup files.
*	Minor fixes and improvements.

## 2.10.0 (2018-04-03)

### Changed
*	Incoming ticketing emails containing "report-type=delivery-status" header are no longer ignored. Thus, new ticket detection on IMAP server will be improved. Detection of "undelivered emails notices" will be handled in v2.11 by configurable email blacklist.
*	Now, when a tax for service plan is defined, it is always used for invoicing regardless of the tax defined in service settings.

### Fixed
*	Failing Authorize.Net sandbox payments. Authorize.Net SDK updated.
*	Fixed ticketing email matching with clients. All client's emails besides those marked as "login" are now used for matching. Additionally, in case the client's email is not unique, the ticket is not matched to any client automatically.
*	Broken email format when "email resend" was used.
*	Order of services shown on automatically created invoices corresponds with the services shown in the client's profile page now.
*	Sample client CSV for batch import extended to comprise all possible client's attributes which can be imported.
*	Minor fixes.

## 2.10.0-beta4 (2018-03-22)

### Changed
*	File upload limit increased from 150M to 500M.

### Fixed
*	FCC geocoding service outage detection improvements.
*	Notifications sent by UCRM are no longer detected as a new ticket in any case now.
*	Fixed problems with some pop-up windows, e.g. when modifying service period length on the invoice form.
*	Minor fixes

## 2.9.3 (2018-03-19)

### Changed
*	Client outstanding amount placeholders now show positive number everywhere.
*	Failed services in FCC report now include reason of failure. Also, GPS geocoding is more resilient to geocoder service errors.
*	PHP updated to version 7.1.15.

### Fixed
*	Data usage report fixes. Previous client's services are now included, fix issues with manually modified data. 
*	Deleting organization with unused service plans is now enabled.
*	Fixed fees being possibly invoiced twice in some cases. Additionally, if there are multiple services invoiced separately, the fees will appear on the proper invoice with the related service as expected.
*	Fixed rendering and UI/UX issues on iPad.
*	All recurring payment subscriptions are disabled properly now when the feature is turned off in system settings.
*	When the super-admin's email is changed, it is now properly used as the recipient address for all outgoing emails while the UCRM demo mode is on.
*	Fixed issues after demo mode factory reset.
*	Fixed issues with HTML body of incoming ticketing email.
*	Fixed "create invoice X days in advance" validation in billing settings.
*	Fixed service charts rendering issue.
*	Minor fixes.

## 2.10.0-beta3 (2018-02-23)

### Fixed
*	Fixed localization issue preventing login after update to 2.10.0-beta2.
*	Fixed problem in FCC report generation.
*	Fixed address not pre-filled, when new job is created from client's detail page.
*	Fixed NetFlow charts not visible in admin zone in some cases, when there are data available.
*	Minor UI fixes.

## 2.10.0-beta2 (2018-02-22)

### Added
*	Improved design of the client log.
*	Improvements to Service Device API. Now it's possible to edit service device and delete service IPs.
*	Czech localization added.

### Changed
*	Custom SSL certificate can be now used with IP address only (with no server domain defined in system settings). Server domain remains required for Let's Encrypt. Also, when server IP / domain is changed, the server configuration is regenerated automatically (no need to re-upload the certificates or restart UCRM).

### Fixed
*	Creating a canned ticketing response failing when longer text was used.
*	Client count is no longer displayed on dashboard for users without view permission for clients.
*	Fixed permission error with canned responses in Client Zone Support section.
*	Minor UI/UX fixes.

## 2.9.2 (2018-02-21)

### Fixed
*	Fixed download of job attachments.
*	Invoices not created automatically on time. A delay of several days occured in some cases in February for Forward invoicing.
*	Improved FCC report generating which can handle thousands of clients.
*	Fixed NetFlow chart not shown in client zone when the service has no service device.
*	Invoice couldn't be edited due to missing invoicing address. Validation error is now shown properly in this case.
*	Better file type recognition when uploading client's documents.
*	Fix of possibly failing outgoing emails and other recurring backend tasks.
*	Fixed created date validation on payment forms.
*	Minor fixes.

## 2.10.0-beta1 (2018-02-14)

### Added
*	Plugins - plugins are open source modules which can be uploaded into UCRM. Check out the [Plugins repository](https://github.com/Ubiquiti-App/UCRM-plugins).
*	Webhooks - configurable URL endpoints which will be automatically triggered in case of actions related to invoicing (such as a new invoice or new payment created). Additionally, you can set any plugin (its public URL) as the webhook endpoint.
*	Canned responses for Ticketing.
*	Automatic remote backups for UCRM backup files (sync with Dropbox).
*	New improved wizard and users onboarding for the first run.
*	UX Improvements (SSL certificate near expiration date notification, creating a service plan while adding a client's service, etc.)
*	New option for FCC reporting: use the GPS coordinates of the client's service as the primary source for FCC Census geocoder (instead of the address). Additionally, you can check, set or change the FCC Block ID manually for each client's service.
*	More placeholders are now available in customizable notifications and bulk email tool.
*	API enhancements: invoice email can be sent via API and the invoice emailSentDate attribute can be set or changed.
*	Improved notifications in case of FCC Geocoder service outage.

### Changed
*	After tickets or ticket comments are imported to UCRM, they are automatically marked as read in the source IMAP inbox.
*	Improved outgoing email format, the plain text version is attached to the email to prevent it from being marked as spam.

## 2.9.1 (2018-02-13)

### Fixed
*	Some main menu items not accessible for some users even with sufficient permissions.
*	Creating a job with assigned client failing in some cases.
*	Fixed for possible issues with Google Calendar sync.
*	Minor fixes for add new payment form.

## 2.9.0 (2018-02-12)

### Added
*	Ticket URL added to the default "ticket changed status" email notification.
*	Support for new Stripe API version "2018-02-05".
*	French localization added.

### Changed
*	Ticket ID added to all ticket notifications' subject and message body for a better merging of incoming emails to the right existing ticket (This kind of fallback merging is used when the mail server trims some email headers, applied only when the sender email matches some of the client's email).
*	Client's quotes are shown on client profile page and in Billing > Quotes section (Quotes tab was removed from Client).
*	PHP updated to version 7.1.14.

### Fixed
*	Fix permanent syncing of Mikrotik routers.
*	Fixed airOS shaper causing Wireless Security misconfiguration in some rare cases.
*	Fixed UI for the main menu on mobile view.
*	Fixes and improvements for Ticketing API.
*	Fixed version validation for the UCRM backup restore feature in the initial wizard.
*	Improved validations for Client CSV import.
*	New payment button not working on client's invoice detail page.
*	Improved ACH payments, displaying the pending status now.
*	Minor fixes, guide improvements.

## 2.9.0-beta3 (2018-01-19)

### Added
*	API extended with ticketing groups management.

### Changed
*	Bank account is now hidden in the Stripe ACH payment overview.
*	"Portuguese PT" set as the default fallback language for missing "Portuguese BR" translations.

### Fixed
*	Fixed error in the manual editing of client's NetFlow data usage.
*	Fixed disappearing IMAP inbox settings when a ticket is deleted.
*	Fixed crashes when IMAP inbox settings are deleted and "Show original" or "Show attachment" is requested on a related ticket.
*	Security fixes.
*	Minor fixes.

## 2.8.2 (2018-01-19)

### Added
*	New currency TZS.

### Changed
*	Stronger SSL ciphers are now used in the built-in nginx server when UCRM HTTPS is enabled.

### Fixed
*	Search tool not giving proper results after batch import of Client CSV file.
*	All imported clients from CSV file, have all billing attributes set as "use system default" now.
*	Fixed client's email reply on "Ticket change status" notification triggering a new ticket. Now it creates a new comment in the existing ticket thread properly.
*	Fixed drag & drop feature on the Scheduling Timeline. This issue appeared in Windows only.
*	Fixed IPPay forms in browsers not supporting HTML5 validation. Causing crashes when the card num / expiration / cvv fields were sent empty.
*	Minor fixes and UI/UX improvements.
*	Security fixes.
*	API doc fixes.

## 2.9.0-beta2 (2018-01-11)

### Added
*	Now, the client's ID accompanies the client's name in every drop-down menu enabling you to choose the proper client.
*	UX Improvements, such as a link to view all client's jobs on client's profile page.
*	Translations updated.

### Fixed
*	Possibly failing upgrade to 2.9.0-beta1 in some rare cases.
*	Fixed notification for a new ticket with only attachment and no text.
*	Fixed private ticket headers visible in client zone (not the comments or attachments though) and other minor fixes for Ticketing.
*	Fixed disappearing of the Ticketing IMAP settings.
*	Errors in managing ticket attachments.
*	Minor security fixes.
*	Minor fixes.

## 2.8.1 (2018-01-11)

### Changed
*	PHP updated to version 7.1.13.

### Fixed
*	Several security fixes.
*	Possible error when editing Service Plan.
*	Failing job attachment upload for some rare mime types.
*	Fix CSV import when zero date is present.
*	Fixed Stripe ACH section being visible in client profile page and in create subscription page when ACH is disabled in the System Settings.
*	Ending a service with pending deferred change is disabled now. The planned deferred change must be removed first to avoid inconsistent service state.
*	Minor fixes

## 2.9.0-beta1 (2018-01-05)

### Added
*	Service Quotes. When creating a client's service, you can mark it as "Quoted". Then, you can create a quote (similar to invoice) and when the quote is accepted, the service will be automatically activated.
*	Client's NetFlow data usage can be manually edited. Check out the client's service NetFlow - table view.
*	New feature to create a new ticket from a client call log (manual client log entry).
*	Multiple Ticketing IMAP inboxes are configurable now. Each inbox can be associated with some User Group which is responsible for handling related tickets.
*	Check out the number at the ticket title indicating the count of new replies which you haven't read yet.
*	New filters for Ticketing. Now, you can find tickets having the latest comment created by client, i.e. tickets which probably need some attention.
*	API enhancements - IPpay payment subscription can be created in UCRM using the API.
*	UX improvements (Surcharge tax is now visible when creating a new service, etc)
*	UI/UX improvements, such as invoice pay button directly on the invoice grid, better service selection when invoicing ended or obsolete services, etc.
*	New way how to print the payment. Use the print button on the payment detail page and modify the page layout etc. on your own.
*	Notes added to UCRM payments are now editable.
*	Improved Ticketing UI in Client Zone.
*	New localizations added: Slovak, Danish.

### Changed
*	Improved Data Usage Report. Upload, download and period are now in separate columns.
*	Configuration of the login page banner moved from Organization settings to the Appearance section.
*	Service tax summary improved in the service details box. The service surcharge tax is always shown now. (Before, it was included only when the surcharge tax and the service tax were the same.)

## 2.8.0 (2018-01-05)

### Added
*	You can choose whether to use system default IDs for your clients (starting from 1) or a custom ID defined by you (starting from any number). Then, the selected ID will be shown everywhere throughout the system including the Client Zone. (Note, that all API data clients data remains to be identified be the default system ID.)

### Fixed
*	Errors in permanent deletion of client in some cases.
*	Private ticket attachments were downloadable by clients (although they were not visible).
*	Minor security fixes.
*	Improved validation for Ticketing autoreply template.
*	Fixed taxes overview in service detail and in invoice form (not all the taxes or previously removed taxes were shown in some rare cases).
*	New lines in ticket comments are well formated also in related email notifications now.
*	Email resending is now disabled in case the email log entry has no recipient defined.
*	Wrong type of template was used for ticketing notifications working (in some cases when IMAP integration is enabled).
*	State was ignored in Clients CSV import.
*	Minor fixes.

## 2.7.8 (2017-12-22)

### Fixed
*	Fixed import of Payments CSV file.

## 2.8.0-beta4 (2017-12-20)

### Fixed
*	Better results for the header search bar tool.
*	Help guide updated.
* Fixed Payments CSV import in System > Tools > CSV Import.
*	Minor UI fixes and improvements.

## 2.7.7 (2017-12-20)

### Fixed
*	Fixed permission check for several actions.
*	Fixed client's outage badge disappearing for a short while after some service was edited.
*	Fixed synchronisation of airOS traffic shaping for CPE devices.
*	Suspension page fixes. Failures when two clients have the same IP. Fixes in URL generated on the suspension page in case HTTPS is used in UCRM.
*	Creating erroneous jobs in the scheduling timeline with double-click was disabled.
*	Service IP unique check was extended to client's detached devices (detached from services). Additionally, you can search clients with IP address of these detached devices now. API validation for unique client IP was also added for creating new service device.
*	Fixed custom client attributes errors in Client CSV export.
*	Fixed service editing form in case the related service plan's period is no longer available. (Existing services can still use it, but new service can be created only with enabled service plan periods.)
*	Date picker not rendering correctly and other minor UI/UX fixes.
*	Minor fixes in service "Contract section". Now, the displayed early termination fee price corresponds with service parameters, not previously created fee.
*	Super admin account cannot be deactivated now.

## 2.8.0-beta3 (2017-12-07)

### Added
*	"US half letter" format added to PDF export options.
*	New link to client added to the invoice detail page.
*	Unknown service devices are no longer synchronized.
*	WalkMe guides added to UCRM online demo.
*	Menu shortcuts UI/UX improvements.

### Fixed
*	Fixed failing QoS setup on EdgeOS of unknown version.
*	No Ticketing search results are shown for users without appropriate permissions.
*	Minor fixes.

## 2.7.6 (2017-12-07)

### Fixed
*	Improved Client CSV validations preventing import failures.
*	Taxes associated with service were always applied to surcharges despite the defined tax of the surcharge. Now the surcharge tax (when defined) overrides the taxes of the service or the client correctly.
*	Help section is shown as the last one while using the header search bar tool.
*	Better validations and minor fixes for Stripe webhooks and Client custom attributes.
*	Possible bug with Authorize.Net post-dated payment not being imported into UCRM.
*	HTML sanitized for email templates preview.
*	More tooltips and guides improvements.
*	Belarus currency code fixed from BYR to BYN.
*	PHP upgraded to version 7.1.12.

## 2.8.0-beta2 (2017-11-20)

### Added
*	Improved Stripe ACH guides and tooltips.
*	UCRM with edgeOS v. 1.10+ is able to shape a higher number of clients now, around 16,000.

### Changed
*	Changed Elasticsearch priorities to show better results.
*	Data usage report now contains suspended services as well.
*	Organization logo and the banner is taken from the only configured organization automatically. In case there is more than one organization, it is taken from the one marked as "default".

### Fixed
*	Data usage report failing to generate in some cases.
*	Dashboard financial information toggle is persistent even after a page reload.
*	API fixes related to private tickets and other API improvements.
*	Manually terminated suspensions (caused by past due invoices) are not reactivated automatically until a new past due invoice occurs.
*	Fixed job edit when duration is empty.
*	Fixed form submit in Microsoft Edge browser.
*	Minor fixes.

## 2.7.5 (2017-11-16)

### Added
*	Improvements for CSV Import feature. Imported payment can be associated with a client. You can also use a sample CSV.

### Fixed
*	Failing service deferred change cancellation and deleting.
*	Failing emails sending in case of an invalid email address (empty string values created in an older version or through API).
*	Better results for the header search bar. (For example, results with exact invoice number match are always shown first. Client's service can be found by a note, etc.)
*	Better validations for creating a ticket with API.
*	Ticket comments created with API were always public.
*	Fixed minor bug on invoice form. (Recalculation failed when created date was not set.)
*	Minor fixes.

## 2.8.0-beta1 (2017-11-08)

### Added
*	Extended Data usage report.
*	ACH payments enabled for Stripe.
*	API enhancements: Services can be filtered by their status which may be useful to get the IPs of all suspended clients. Clients and Invoices can be filtered and sorted within the GET method. Unassigned jobs and tickets can be now filtered.
*	New features for Ticketing: Automatic reply for client's tickets created through email sent to the IMAP inbox; Option to merge unknown email address from ticket reply into client's contacts.
*	Major Ticketing UI/UX improvements. Chat style introduced.
*	Major Suspension page improvement. Clients are now enabled to pay online directly from the suspension page without entering the client-zone. Clients just click on Postpone suspension and are redirected to the payment page. No login is required.
*	Additionally, clients can reactivate their own terminated service. You can configure this in System > Settings > Client zone.
*	Added more printing page sizes for Invoice, Payment receipt and General PDF export in System Settings.
*	You can define your own shortcuts for frequently used pages, see the left-hand side panel.
*	Scheduling UI improvements.
*	As an administrator you can create private tickets now and ticket attachments are deletable now.
*	Improved header search tool, company can be found by contact name.
*	Date and time added to the new payment form.
*	A new option in service plan settings to include its instances (i.e. client's services) in FCC reports.
*	Improved client import tool for importing UCRM CSV files or any custom CSV files with multiple phones or emails in a single field separated by a comma.
*	New notification templates: for ticket comments with enabled and disabled IMAP integration. You can define ticketing email template which suits you the most.
*	You can now customize two versions of suspension page: for past due clients and for any other suspension reasons.
*	Excluded NetFlow IPs. NetFlow traffic between clients and these IPs will not be involved in the client's data usage.
*	New configuration for Client Zone and client-related features available in UCRM system settings. For example, you can enable service reactivation, suspension postponing, show more payment details, etc.
*	New settings section: Customization (formerly: Notifications) where you can configure many email templates, invoice template, suspension page, UCRM appearance, etc.
*	Custom favicon configurable in System > Customization > Appearance.
*	Client contacts enhancements. Now, for each contact, you can set a name and a default or custom type.
*	UX improvements and minor fixes.
*	Improved app performance.

### Changed
*	Attaching a file without a text to a ticket is now possible.
*	Client ID is now the primary ID used for clients (in the URL, in API, in client profile). You can still define client's Custom ID (formerly User Ident) and use both as placeholder in any notification and use it in the search bar.
*	You can define 2 date formats in system settings: "Default date format" which is used for UCRM frontend and "Alternative date format" for printed documents such as invoices and payment receipts.
*	Billing reports moved to new main menu section Reports.
*	Client list is ordered by client ID (newest first) as default.
*	An option to create a credit from an overpayment was removed from client's payment page. All invoices are paid by default in case of an overpayment created by client.
*	Client's outstanding is now shown as a positive number.
*	Subscription cancelled notification templates for each payment gateway were replaced with a single template with placeholders.
*	Better UCRM anonymous statistics, read more in in-app user guide.
*	Some docker containers removed.

### Fixed
*	Fixed creating new collection items in several forms.
*	"Recognized suspension page" is correctly shown for clients having IP range assigned to the suspended service.

## 2.7.4 (2017-11-08)

### Added
*	Translations updated.

### Fixed
*	Fixed slow dashboard loading.
*	Stripe subscription payments not matched to invoices. Instead, they were turned into client's credit in some cases.
*	Fixed termination of service suspension in some cases when a new payment is received but more than one invoice is overdue.
*	Elasticsearch index properly initialized after UCRM is restored from backup.
*	Minor fixes.

## 2.7.3 (2017-11-02)

### Added
*	More logs of device synchronization are now available on the device detail page.

### Fixed
*	Fixed issue with multiple overdue invoices with long suspension delay causing suspension not being terminated after a payment.
*	Fixed job duration in exports.
*	Fixed invalid errors with form submit with hidden elements (e.g. new job with empty task)
*	IMAP ticket with attachments not created in some rare cases and fixed attachments download for IMAP tickets.
*	Fixed device sync issues and issues with creating device backup file.
*	Fixed creating ticket comment with empty attachment file through API.

## 2.7.2 (2017-10-31)

### Added
*	UX improvements.
*	Added BDT currency.
*	Improved searching by client's ID number.

### Changed
*	API improvements for Ticketing (added filters, sort and limit options) and ticket comments refactored to activities involving both comments and ticket log entries.
*	PHP updated to version 7.1.11.

### Fixed
*	NetFlow data being labeled with wrong time in some cases when non-UTC timezone is used.
*	Postponed suspension of a service is properly canceled when a new payment is created for past due invoice.
*	Fixed searching invoices and payments by client's name.
*	Fixed crashes caused by errors during generating invoice PDF.
*	Fixed service suspension not being terminated automatically after a new payment in several cases.
*	Minor fixes

## 2.7.1 (2017-10-13)

### Changed
*	Authorize.Net payment form in UCRM no longer requires CCV code.
*	Improved server port tooltip to say SSL certificate must be set up before HTTPS can be used.

### Fixed
*	Fixed matching Stripe payments to wrong clients when they were not requested by UCRM.
*	Fixed Authorize.Net subscription creation crashing in rare case.
*	Fixed CSV import crashing without any error when item count over limit.
*	Fixed XSS vulnerability in client zone support form and in more text toggle
*	Fixed service taxes not showing in edit form when they were set up before.
*	Reworked file permissions handling at UCRM boot fixing the hanging boot problem.

## 2.7.0 (2017-10-06)
Incorporates all new features and fixes from 2.7.0-beta1 up to 2.7.0-beta4
 
## 2.7.0-beta4 (2017-10-06)

### Fixed
*	Fixed placeholder usage in the New Ticket notification for admins and other minor fixes.

## 2.7.0-beta3 (2017-10-04)

### Added
*	IMAP connection check added to the dashboard.
*	New troubleshooting guide for Unresolved host error (also related to outgoing emails failures).
*	Improved Authorize.Net guide for recurring payments.
*	You can view email original for each ticket comment sent by a client into the Ticketing IMAP inbox.
*	API enhancements for Ticketing and Scheduling.
*	Links in flash messages are now clickable.
*	Translations updated.

### Changed
*	App speed improvements, static suspension redirect page added to minimize server load.
*	Better shaping on airOS devices. Device restarts are no longer needed and device connection to UNMS is not affected.
*	When the status of a queued job is changed, the job is automatically assigned to the current user and job datetime is set to the current timestamp.
*	Recurring payments are off by default in new UCRM installations because it needs some additional paygate configuration before it's turned on in UCRM.
*	PHP updated to version 7.1.10.

### Fixed
*	IPpay payments not delivered to UCRM.
*	Fixed possible problem when UCRM boot hanged at "Initializing: Dirs".
*	Fixed deleting clients with uninvoiced fees.
*	Fixed creating tickets with attachments from IMAP integration.
*	New UCRM Installer version 1.4. Fixing issue with the permissions when the user "ucrm" already exists.
*	Fixed Service device modal window throwing error "Resource not found" when the associated network device has been deleted.
*	Fixed matching and editation of payments with "Custom" method (created via API).
*	Minor fixes and UI improvements.

## 2.7.0-beta2 (2017-09-14)

### Fixed
*	Failing MercadoPago IPN.
*	Proper data pruning for UCRM sandbox termination.
*	Fixed dashboard data permissions for the mobile app.
*	Minor fixes in the Reporting section.
*	Minor UI, UX fixes.

## 2.7.0-beta1 (2017-09-12)

### Added
*	Automatic service setup fee and early-termination fee. Configurable in System > Items > Service plans. Also, note that Service contract length was renamed to Minimum contract length.
*	IMAP Integration for Ticketing. You can bind your mailbox with the Ticketing module which will create a new ticket or ticket comment from every incoming email.
*	MercadoPago payment gateway integrated to UCRM. Now you can use many payment methods like OXXO, Boleto and many other credit, debit, and cash payments, including payment subscriptions.
*	Now, you can define taxes for service plans, products, surcharges or fees. If this tax is set, it will be always used for invoicing regardless of the taxes associated with the client. Typically, this is used in non-US countries.
*	2-factor authentication. You can enhance the app security by enabling 2-factor authentication for your UCRM user account.
*	UCRM Mobile app connectivity. Get your QR connection code from your personal account page.
*	Better web responsivity, client zone adjusted for mobile usage.
*	Major app speed improvements and better grids filtering and sorting.
*	You can enable/disable clients to postpone their service suspension by 24 hours. In System > Billing > Suspension.
*	Connection all payment gateways is checked. When an error occurs, a warning is shown on the dashboard.
*	API extensions, new payments can be automatically attached to client's invoice, payment receipt can be sent using API, user's credentials authentication, and other API extensions.
*	File attachments enabled for Tickets and Scheduled jobs.
*	Services with postponed suspension are visibly labeled and the suspension can be repeatedly postponed by the administrator.
*	Payment receipts are printable / downloadable now.
*	Improved Batch Mailing module - placeholders, UX improvements.
*	You can modify UCRM look using your own CSS. (Go to System > Tools > Custom CSS)
*	Many UI/UX Improvements, more tooltips and in-app guides.

### Changed
*	Deferred change is available even for prepared services now.
*	Assigning of administrators to a ticket is now visible in the ticket's log of communication and events.

### Fixed
*	Fixed job duration in my jobs agenda view.
*	Fixed sending empty "invoice generated" notifications.
*	Minor fixes.
*	Fixed minor security issues with uploading webroot files and restoring UCRM from a malicious backup file.
*	Client's data usage table not including data for the first or last day of the billing period in some cases.

## 2.6.2 (2017-09-05)

### Added
*	Troubleshooting guide for setting up Stripe payments.
*	Better UX for CSV and PDF exports. Empty files are not marked as a failure.
*	New currencies added: DZD, MAD.

### Changed
*	Current client email is used for Stripe payments instead of the email saved on the invoice.
*	PHP updated to version 7.1.9.

### Fixed
*	Failing client export to CSV.
*	Failing database restore in some cases.
*	Possible SMTP timeouts bug with some servers.
*	Possible problems with turning off the maintenance mode after UCRM upgrade.
*	Broken FCC Broadband Subscription report generation.
*	Fixed view permissions for some system settings pages.

## 2.6.1 (2017-08-16)

### Fixed
*	Failing Let's Encrypt tool.
*	Several form fields validations added for security reasons.
*	Better error handling while starting UCRM.
*	Failing payment adding using API in case there are more organizations with different currencies in UCRM. Additionally, the payment currency can be set. If not set, it is derived from the client's organization.

### Added

## 2.6.0 (2017-08-10)

### Added
*	New currencies added: Central and West African CFA franc.

### Fixed
*	App security extensions.

## 2.6.0-beta3 (2017-08-08)

### Added
*	Tickets can be deleted now, in a batch also. Additionally, creating tickets from the client-zone support form can be turned off in System > Settings.
*	Added SLL currency - Sierra Leonean leone.

### Changed
*	Organization name is shown instead of username in the ticket reply header in the client zone.
*	"Use credit" toggle is now shown only when creating a new invoice or editing a draft invoice.
*	PHP updated to version 7.1.8.

### Fixed
*	Periods in Data Usage table are shown correctly regardless of any changes in invoicing parameters made to a service.
*	Access denied to ticketing module even for administrators with proper access rights.
*	Buttons for edit / delete client logs not working.
*	Shaping rules synchronization not working when the description of shaping queue was modified manually on the router.
*	Device outages doubled in notification message in a specific case.
*	Service suspended falsely when deferred change is applied.
*	Failing PayPal subscription setup (appeared as of v. 2.6.0-beta1)
*	Minor security fix (Content Security Policy) added to system notifications.
*	Better search results for Elasticsearch.
*	Several minor fixes and additional validations.

## 2.6.0-beta2 (2017-07-28)

### Added
*	Payment subscriptions can be removed from UCRM even without connection to the payment gateway.
*	App speed improvements for client's detail page having many log entries.

### Changed
*	NetFlow auto setup now available only for EdgeRouters.
*	Ticket notifications are sent from the support email address now.

### Fixed
*	No shaping burst was set on airOS devices with egress only shaping.
*	Payments coming from IPpay subscriptions are labeled correctly now.
*	User-friendly notification shown when a client cannot be deleted due to an existing payment subscription.
*	Minor data adjustments when submitting Authorize.Net payment form.
*	Failing IPpay payments and subscriptions with CC expiration month in October.
*	XSS vulnerability in scheduling timeline.
*	UI fixes and improvements.

## 2.6.0-beta1 (2017-07-14)

### Added
*	Ticketing module. Ticket is automatically created when a client sends a request from the client zone. Features: keep track of the communication, assign it to an administrator, mark as solved, manage with API.
*	Bulk emailing module. You can send an email to a subset of your clients in System > Tools > Mailing.
*	Scheduling improvements. Now you can add tasks into a job which can be used as TODO list.
*	Custom clients' tags. You can create a custom tag (such as VIP or Downloader) and associate it with client. Then you can also filter clients by these tags.
*	Google calendar synchronization. Sync your UCRM jobs into your google calendar account.
*	IPpay automatic subscription payments. Administrators or clients can set up recurring payments using IPpay.
*	Shaping burst for airOS CPE devices. Define the download and upload burst for each service plan in System > Items.
*	In-app upgrade feature. As of this version, you will be notified about a new version available and you can upgrade to it using a single button. 
*	All important grids can be exported to CSV or PDF now.
*	Now you can resend any email whose sending failed. Go to client's email log or system email log.
*	New system notification settings - decide whether to send them by email or into the header notification status bar. Go to System > Notifications > Settings.
*	Notifications preview. Now you can get a preview of all system and client's notifications.
*	Now, you can upload your customized background for UCRM login screen.
*	Better client status indicators. You can now see the "invitation email pending" status until it is really sent from the email queue successfully.	
*	New placeholders now available for client notifications, for example client ID, username or client's account balance information.
*	Client zone UX improvement. Unpaid invoices are shown on the top of the client's dashboard page.
*	Initial UCRM setup wizard requires credentials now due to security reasons. These credentials are generated at the end of installation process.
*	Custom client attributes can be managed by UCRM API now.
*	More service default parameters can be defined in System > Billing.	
*	Now, you can view the log of the SSL certificate upload and setup in System > Tools > SSL Certificate.

### Changed
*	Various UX/UI improvements on the dashboard, scheduling module, etc.
*	Better confirmation messages.
*	The manual suspension is allowed only while using a custom suspension reason. "Payments overdue" reason is now applied automatically only.
*	Now, you can manually invoice a service which has been or will be modified (using the deferred change).
*	Improvements for Elasticsearch in the header bar - speed improvements and failure detection shown on the dashboard.
*	Clients export feature extended. Now all clients data including custom attributes are exported.

### Fixed
*	Fixed possible bug in the duration of separately prorated invoice periods.
*	Wrong service price - no prorating was applied when Period Start Day is set to "last" and Invoicing From is between 29th and 31th.
*	Header bar search failed for some entities, such as searching clients by IP.

## 2.5.3 (2017-07-13)

### Added
*	PHP updated to version 7.1.7.

### Fixed
*	Failing HTTPS setup with custom SSL certificate upload.

## 2.5.2 (2017-07-10)

### Added
*	Service status now available in UCRM API.
*	Added missing provinces for Canada.

### Fixed
*	Custom client attributes not shown in some cases when custom invoice template was used.
*	No taxes applied automatically when adding a late fee to an invoice manually.
*	Flag for "Separate invoicing of prorated period" was ignored in automatic recurring invoicing in some rare cases.
*	Better error handling when setting up Stripe recurring payments.

## 2.5.1 (2017-06-30)

### Fixed
*	Broken item selection in grids for exports into CSV or PDF.
*	Invoices not automatically generated on a proper day for Backward Invoicing. ("Create X days in advance" parameter ignored.)
*	These API calls fixed: GET ServiceDevice, GET ServiceSurcharge for the service and GET ServiceIp for the serviceDevice.
*	NetFlow download data fixed. UCRM auto NetFlow setup now uses "netflow enable-egress" option for NetFlow version 9.
*	Minor fixes in device outage detection and NetFlow data collecting.

## 2.5.0 (2017-06-22)

### Changed
*	PHP updated to version 7.1.6.
*	Translations updated.

### Fixed
*	Proper error handling when creating payment subscription failed for PayPal and Authorize.Net.
*	Fixed possible malfunction of automatic SSL setup using Let's Encrypt.
*	Fixed excessive automatic creation of late fees from a single overdue invoice.
*	When archiving clients their ended services' End Date is not modified now.
*	Fixed invoice sorting by due date.
*	CSRF Protection and minor fixes.
*	Fixed permissions check for job editing actions.
*	Minor UI fixes.

## 2.5.0-beta4 (2017-06-12)

### Changed
*	UX Improvements.

### Fixed
*	Fixed permanent client deletion.
*	Fixed creating invoices X days in advance for Forward Invoicing.

## 2.4.3 (2017-06-12)

### Changed
*	Maximum file size for Organization logo and stamp is now limited to 2 MB.
*	UX Improvement - services with postponed suspension are marked with a label.

### Fixed
*	Fixed suspension of service IPs with a netmask on Mikrotik devices.
*	Repeated suspension postponing by a client is forbidden again. This feature is possible only once per each suspension.
*	Fixed permission issue when changing own password.
*	Blocking a prepared service till the activation date not working for services after reactivation.
*	CSRF protection for document uploads.
*	Other minor fixes.

## 2.5.0-beta3 (2017-06-05)

### Fixed
*	Fixed suspension synchronization.
*	Fixed client permanent delete.
*	Minor UI fixes.

## 2.5.0-beta2 (2017-06-02)

### Changed
*	Minor scheduling UX improvements.

### Fixed
*	Fix Top Downloaders filter.
*	Fixed growing chart in Safari.
*	Minor fixes.

## 2.4.2 (2017-06-02)

### Fixed
*	Fix credit being duplicated after it's used to pay for invoice. All payments are checked and if the credit was created wrongly, it will be removed from the invoice. Make sure to check your invoices after updating. Only payments / invoices created after version 2.3.0-beta1 could be affected by this bug.
*	Fixed walled garden postpone suspension button not working after it was used for previous suspension.

## 2.5.0-beta1 (2017-05-31)

### Added
*	New Scheduling Module. Create a job, monitor its life-cycle, assign it to an administrator. Additionally, all jobs can be exported and linked to your own calendar (iCal) or managed by UCRM API.
*	Antiflood and Throttler for UCRM mailer. You can turn on these new features to accommodate the needs of your mail server.
*	Custom Client Attributes. You can create a custom attribute and associate it to a client. You can also modify the invoice template to include that attribute.
*	Courtesy credit. You can create courtesy credit for a client. This works as any other payment, which increases client's credit but this credit cannot be refunded.
*	UCRM translations per administrator. Each administrator can set up his own language in the user profile. This will affect the user's view while the app localization remains applied to invoicing and client zone (still configurable in System > Settings > Localization).
*	IPpay one-time payments integrated into UCRM.
*	New placeholders are now available in custom invoice template. For example client's account standing or credit can be added to the invoice now.
*	Late fees can be configured separately regardless of the suspension feature being active. You can also define the delay which will determine when the late fee will be applied after the due date.
*	Top downloaders list. View all NetFlow data for all the clients. See Dashboard > Top downloaders > Show all clients.
*	Added Data Usage overview in a grid on client's service page. The usage is organized according to the service periods. This can be used for manual data usage billing.
*	Minimum unpaid amount to trigger suspension. Now, you can define the minimum unpaid amount of an overdue invoice to trigger the suspension. See System > Billing > Suspension.
*	You can restore a database backup in the UCRM wizard. No need to initialize whole UCRM before restoring a backup.
*	UCRM API enhancements. Now, you can create new taxes and also apply tax to an invoice item. Additionally, you can manage client's log using the API.
*	Hungarian translation added (still incomplete, translation is in progress).
*	Fancy UX improvements.

### Changed
*	The size of organization logo thumbnail in invoice templates is changed from 260x80px to 200x200px, to correspond with size of organization stamp thumbnail. Additionally you can use new invoice template variable to use original image size for both logo and stamp.
*	Better UX for client log. Now all messages are merged into a single grid giving you a better overview.
*	While a service is suspended for a whole billing period, this period is not invoiced if "Stop invoicing for suspended services" is true. All other periods even partially suspended will be invoiced as usual. Note that this option is irrelevant for prepaid services, i.e. forward invoicing.
*	For security reasons, the mail server password must be provided each time the mailer parameters are edited.
*	Suspension and Late fee features are turned off by default for new UCRM installations.

### Fixed
*	Count of Device outages shown on dashboard now complies with the default grid filters used in Network > Outages section.
*	Minor fixes related to deferred services.

## 2.4.1 (2017-05-30)

### Fixed
*	Postpone suspension button not working on client's suspension (walled garden) page. 

## 2.4.0 (2017-05-25)

### Fixed
*	Failing to mark all header notifications as read.
*	Grid sorting errors, various form validations and other minor fixes.
*	Failing Authorize.Net subscriptions due to a long client name.
*	XSS Vulnerability fixed.
*	UX fixes and improvements.

## 2.4.0-beta2 (2017-05-16)

### Added
*	New filter for device outages grid. Now, you can filter out all the outages of devices with turned off outage notifications.
*	SZL (Swazi Lilangeni) currency added.

### Changed
*	When client postpones the suspension, the suspension will be reactivated after 24 hours (before, it was reactivated after the today's midnight).
*	Higher contrast added for input fields to improve user experience when UCRM is used outside under the sun.
*	PHP upgraded to v. 7.1.5.

### Fixed
*	Fixed getting all VLAN interfaces and advanced information from airOS devices.
*	Fixed wrong timezone being used giving wrong results for several actions and views. Now the proper timezone of your UCRM is always used.
*	Added CSRF protection.
*	Minor fixes.

## 2.3.3 (2017-05-16)

### Fixed
*	Suspension not working and suspension notification repeatedly sent every hour. This might happen after the "Demo mode" has been terminated.

## 2.4.0-beta1 (2017-05-03)

### Added
*	Added fully automated HTTPS setup. Now, you can set up SSL certificates using Let's Encrypt. UCRM will automatically handle everything for you, including certificate renewal.
*	New Client Documents module added. You can upload any document related to your client, such as contracts, images, PDF files, etc.
*	FCC 477 Reporting. Two CSV exports (Fixed Broadband Deployment, Fixed Broadband Subscription) are available in System > Tools > FCC Reports
*	Tax inclusive pricing. Now, you can define service or product prices with tax included. You can switch to this pricing mode in System > Billing or in the initial setup wizard.
*	Added device management IP. Now, you can provide a CPE or any other device of your network with a management IP. Then, this IP will be used for all UCRM connections to the device (sync, outage detection and signal statistics) while the suspension will normally be applied to standard IP(s) of the CPE device.
*	Now, you can search client, invoice, device or site by their notes. (In the header search bar)
*	Now, the "new drafts created" notification contains a brief overview of the invoices with a link to each of them. If you have already modified the content of this notification, you can add this overview manually in System > Notifications settings.
*	Date, when the next recurring invoice will be generated, is shown on service view page.
*	UCRM backup extended. Now you can define whether to backup also important files and documents along with the whole database. (System > Tools > Backup)
*	On device view page, IP addresses and notes are now included in interface list.
*	Now, there are two types of "new invoice" notifications for administrators - for drafts and for auto-approved invoices. You can customize both or even turn them off (in System > Notifications > Settings).
*	NetFlow graphs refresh interval can be set up in System > Settings > Netflow
*	UCRM API improvements, you can edit client's services and invoices. You can also get invoice templates stored in UCRM.
*	All notifications and emails can be turned on / off in System > Notifications > Settings. You can even suppress invoice sending.
*	You can now define the minimal data traffic for "NetFlow unknown device" detection.
*	Decimal and thousand separators can be defined in System > Settings > Localization
*	CSRF protection for several pages.
*	Notification about new UCRM version added to header toolbar.
*	UX Improvements and minor fixes

### Changed
*	Invoice rounding mode "Precise non-rounded item totals" is deprecated now. It was used as a temporary workaround for determining the final service price with tax included. Now, we strongly recommend switching to the new Pricing Mode called "tax inclusive pricing".
*	Exports of Billing reports are now generated in the background. When finished, you can download it in System > Tools > Downloads
*	Service surcharge price can be left empty. Then, the default system surcharge price will be used. If left empty, the price will be updated on each service when system default is changed.
*	Changing payment currency is now allowed when matching it with an invoice.
*	While terminating Demo mode, all files are deleted now (when factory reset mode is chosen).
*	Improvements of NetFlow auto-setup for EdgeRouters. NetFlow v.9 and memory table disabling are set by default to improve the router performance.
*	Invoice discount validation improved, now only 0-100% is a valid invoice discount.
*	UCRM Translations updated.

### Fixed
*	Excessive restarts of CPE devices are eliminated. Shaper rules are now applied only when qos-related parameters are changed.
*	Now, device status is detected also before the first synchronization is done.
*	"Last successful synchronization" of a device now really shows the date of last successful sync and not the last sync attempt.

## 2.3.2 (2017-05-02)

### Fixed
*	Possibly invalid invoice numbers are fixed before invoice PDF is created.
*	Proper taxed amount rounding on "service show page" is applied in the same way as on an invoice.
*	Fixed Stripe payment issue with invalid parameters.
*	Minor bug fixes.

## 2.3.1 (2017-04-26)

### Added
*	Client ID can be added to the invoice template using the new placeholder "client.userIdent".

### Fixed
*	Better escaping of possibly harmful strings in CSV exports.
*	Fixed QoS rules synchronization on airOS devices in case service plan speed values are removed.

## 2.3.0 (2017-04-21)

### Changed
*	Escaping of possibly harmful strings in csv exports.

### Fixed
*	Fixed discount rounding to decimal places allowed by the currency.
*	Fixed PayPal payment failures for amounts greater than $999.
*	UCRM API fixed. When getting invoices or payments using date range limit, the end date is now included to the filter.
*	Elasticsearch failures when found entities have just been deleted.
*	Invoice maturity days must not be a negative number now.
*	Possible privilege escalation in the client impersonation feature.
*	Form submit button not working in Microsoft Edge and Internet Explorer browsers.

## 2.3.0-beta4 (2017-04-11)

### Fixed
*	Wrong total untaxed amount in billing reports.
*	Missing edit button added for drafts in the invoice grid.
*	Removed false client's credit entries if they possibly still exist after a related payment is unmatched from client.
*	Fixed possible failures of RouterOS device sync due to wrong SSID format.

## 2.3.0-beta3 (2017-04-07)

### Changed
*	Invoice item quantity is now shown along with the unit label such as "pcs", "meters", etc.
*	Flash message is shown when the Elastic search fails for any reason.
*	Guide for Stripe settings updated to accommodate new Stripe dashboard.
*	UCRM system logging improved (unimportant ping notices are ignored).

### Fixed
*	Crashes when exporting large billing reports (memory limits increased).
*	QoS not being updated when service changed (when service plan upgraded / downgraded to another one).
*	Price of service surcharge could not be set to $0.
*	Integer numbers were not allowed in UCRM API along with float numbers. For example: both formats $10 and $10.00 are now valid.
*	False positive alert in header notifications. In some cases, new notification sign was shown even when there was no new notification.
*	Translations fixes and updates.

## 2.3.0-beta2 (2017-03-31)

### Added
*	Papua New Guinean kina currency added.

### Changed
*	Surcharge invoice label improved. When not defined per service, global surcharge label will be used.
*	Additionally, "name" attribute of service surcharge has been removed from UCRM API.

### Fixed
*	Fixed failures in modal window for editing a service which has been terminated. 
*	Fixed error when deleting payment subscription which has been already removed from Authorize.Net.
*	Fixed crashes when generating too large billing report.
*	Translations update and fixes, better word wrapping on several places.
*	Fixed translations usage in "new invoice" email. Change of UCRM language setting is applied properly in all email notifications.

## 2.2.3 (2017-03-30)

### Fixed
*	Fixed invoice creating with empty surcharge label.
*	Fixed import of airCRM database having email duplicates.
*	Fixed discount rounding. Now, when a service with discount is invoiced manually, the negative amount of discount is rounded in the same way as all other positive numbers on the invoice.
*	Fixed bug when creating an unattached payment with undefined currency.
*	Fixed date time of device outage due to the wrong time zone used. Only new entries will be fixed.
*	Fixed form for creating a new refund.

## 2.3.0-beta1 (2017-03-23)

### Added
*	Customizable invoice templates.
*	Added deferred service change. You can define a service change to be applied on the specified date. The service will be invoiced according to the current parameters till this date (excluding this day). The changes will be applied for the next period starting on this day (including this day).
*	You can reactivate a terminated service (click on the service status label) and while doing so you can also modify any service parameters, e.g. change the billing attributes completely. 
*	UCRM translations added for Spanish, Catalan, Swedish, Turkish, Dutch, Latvian, German, Portuguese and Portuguese (Brazil). Change the UCRM language in System > Settings > Localization.
*	When deleting a client's service you can preserve the service device and attach it later to any other client's service. No need to define the device parameters again.
*	You can automatically send notifications before an invoice gets overdue. Define how many days before the invoice maturity day the notification should be sent - See System > Billing.
*	Server disk space utilization shown on the dashboard. This should prevent from crashes due to running out of free space.
*	Added HTTPS support when UCRM is deployed on a cloud with load balancer. More details and guide here: https://help.ubnt.com/hc/en-us/articles/236007047-UCRM-Install-UCRM-Cloud-using-DigitalOcean
*	You can view device password and you can allow this feature for other UCRM users in special permissions.
*	You can define the default period start day for all new services - System > Billing. You can set a fixed day e.g. 1st day in month or a current day.
*	Now you can manually change address and all other attributes on invoice - choose an invoice and click edit button.
*	System notifications added to the header. You will be notified about files being ready to download or about important errors, warnings.
*	All system logs (prod.log, nginx.log, etc) and all docker logs are compressed daily and the backups are pruned after 14 days.
*	UX improvements in service form.
*	Better UCRM booting log.

### Changed
*	Now, late fee is created for each overdue invoice even when they are related to the same service.
*	Simplified and less restricted invoicing. Now, you are enabled to create an invoice with any billing period even already invoiced. You can also delete any invoice, not only the last one in the row.
*	Less restricted custom payment subscriptions. You or your client can create a subscription at any time and with any amount. The subscription is no longer linked to a service. You can create the subscription for a client directly from the administrator's interface without a need to switch to the client-zone.
*	Now, you are enabled to delete a service having some invoices. Additionally, you can decide whether to keep them or delete them as well.
*	Invoice item quantity is rounded to 6 decimal places now.
*	Invoice subtotal is always shown with the currency symbol. When it is possible, the symbol is also used for each invoice item total.
*	Manual draft approving improved. All invoices are created in the background now.
*	Improvements of recurring invoicing. Services with different periods can be invoiced together (on condition "invoice separately" flag is set to false).
*	Backend maintenance scripts are executed more often. As a consequence, various notifications and status updates are executed earlier.
*	UI improvement - items in price summary overview are shown as links so that you can click on them and edit them, e.g. surcharge, discount or the service itself.
*	Company name is shown in header of client zone when a client of type "Company" is logged in.
*	Editing ActiveFrom date of an active service is no longer possible.
*	Update script improved. All config files are validated now.

### Fixed
*	Invoice is properly created when a service is still "Prepared" and you use forward invoicing.
*	UCRM domain name or server IP is required when outgoing emails are used in UCRM.
*	You are now enabled to set service individual price same as the plan price. This will make the service price fixed even when the plan price is changed in the future.
*	UI fixes and improvements.
*	Minor fixes and improvements.

## 2.2.2 (2017-03-22)

### Changed
*	Map in client zone is hidden now when app keys are not set.

### Fixed
*	Fixed "egress-only" shaping on AirOS v8.
*	Fixed blocked IPs synchronization on RouterOS when the synchronized IP is already blocked manually.

## 2.2.2-beta5 (2017-03-20)

### Changed
*	Payment currency validation added for manual payment matching with an invoice.

### Fixed
*	Fixed transparent background of downloaded charts.
*	Fixed restoring encryption key from UCRM backup when restoring on fresh installation.
*	On linux kernels lower than 3.17 - fixed various crashes and failures to login into UCRM (PHP 7.1.3 incorporated)

## 2.2.2-beta4 (2017-03-13)

### Fixed
*	Fixed failing PayPal payments due to wrong TLS 1.2 support.

## 2.2.2-beta3 (2017-03-10)

### Added
*	UX Improvements: grid sorting persists per each UCRM user, company website is clickable, etc.
*	URLs in email notifications are now clickable.

### Changed
*	"Tax rounding" parameter renamed to "Invoice rounding" in System > Billing > Invoicing. There are two options: "Standard rounding", which is default and recommended and "Precise non-rounded invoice item totals" which should be used only if you need to fix the service price with tax included. Note that this option has some limitations, see the in-app help for more details.

### Fixed
*	Fixed NetFlow monitoring after UCRM update. UDP item in conntrack table is purged using new update script.
*	Fixed creating new client while no default organization is defined.
*	Fixed overview of Billing reports.
*	Fixed unknown device count on dashboard.
*	Fixed synchronization of RouterOS VLAN interfaces.
*	Fixed deleting of archived clients.
*	When service is deleted, related shaper rules are removed too.
*	Fixed "NetFlow unknown device" entries when its IP matches the device interface primary IP.
*	Fix unwanted auto-fill of form fields.
*	Fixed CSV import in non-UTF-8 encoding.
*	Minor bug fixes.

## 2.2.2-beta2 (2017-02-23)

### Added
*	UCRM API upgraded with new getters (of collections and single entities too) and new filters for Invoice getter. You can filter Invoices or Payments by the Create date. Please refer to [API documentation for UCRM beta](http://docs.ucrmbeta.apiary.io).
*	Additionally, more attributes of Invoice and Payment can be retrieved using API, for example: invoice status, due date, etc.
*	Enormous app speed improvement.

### Changed
*	Added Canadian provinces into the "States" select-box.
*	PHP updated to v. 7.1.2.

### Fixed
*	Fixed detection of unknown devices connected to airOS network device (the false positives will disappear from the table after a week).
*	Fixed data synchronization for some types of Mikrotik devices.
*	Fixed crashes due to missing indexes of Elasticsearch. Now Elasticsearch data and indexes are persisted in `/home/ucrm/data`.
*	Fixed count of unknown NetFlow devices.
*	Fixed postponing the service suspension and the modal form for postponing always shows tomorrow at least. 
*	Minor fixes and UX improvements.

## 2.2.2-beta1 (2017-02-13)

### Added
*	Introducing robust client contacts management. You can assign an unlimited number of client's contacts with email and phone. Also, you can specify the purpose for each email address, e.g. different email for billing vs. general notifications.
*	And you can import clients with multiple contacts information using UCRM API and CSV import tool.
*	You can also decide whether the client's email should be used as the client-zone username or not.
*	While creating a new service with deferred activation date, you can decide whether to block the service device IP until the service is active.
*	Tax rounding option. You can choose whether to round the taxed amount for the sum of the invoice items (default) or per each invoice item.
*	Better rounding support. Item prices can be defined with up to 6 decimal places while the final invoice item totals and invoice totals are rounded according to the currency decimal limit, e.g. 2 for US dollar.
*	More formatting options added to WYSIWYG editors. For example, you can set font, color or edit the HTML source.
*	Now, you will see all the spool emails immediately in the mailer log. All emails waiting in the queue are shown with flag "E-mail in queue".
*	Emails sent while the demo mode is active are visibly marked in the mailer log.
*	You can set or change the password of your client.
*	Better error message in case the encryption key is missing in the system.
*	Warning shown when trying to assign a range of IPs to the client service because typically, a single IP is assigned to the service.
*	New system settings section Localization - to set system language, timezone, date and time format.
*	State is now loaded to new client form address from default organization as well.
*	App performance improved.
*	You can set logs expiration in system settings.

### Changed
*	You can set default invoicing attributes such as Suspend Delay in system settings. Then, this value will be used globally unless overridden in client's edit page.
*	Now, invoice overdue notifications are sent before the Suspension notification email.
*	NetFlow traffic lower than 1 MB will no longer appear in Unknown devices. E.g. if you just ping non-existing IP, it will not show up in the Unknown device list.
*	Better handling of Stripe webhook failures.
*	By default, invoice label of the service plan is used in the invoice instead of the service name. But you can override this label manually per each service if you want.
*	UX improved for editing network device.
*	Now 6 decimal places are allowed for invoice item quantity.

### Fixed
*	Fixed Client ID auto increment when there is more than one organization in UCRM.
*	Word wrapping fixed in invoice PDF.
*	XSS vulnerability fixed for CSV imports.
*	The process of generating recurring invoices starts exactly at the hour specified in system settings.
*	When clients are archived, their "outage" or "suspend" status is properly removed.
*	Fixed service surcharge order to be the same everywhere.
*	Fixed taxable values in products and surcharges grid.
*	Fixed and improved detection of unknown devices connected to airOS / RouterOS devices.
*	Fixed Authorize.Net duplicate subscription error.

## 2.2.1 (2017-01-24)

### Added
* You can now use wildcards in the search box (* to replace zero and more characters and ? to replace a single character) and boolean operators (+ to indicate the word must be present and - to indicate the word must not be present).
*	Vanuatu Vatu currency added.

### Changed
*	All primary IPs of network devices are excluded from the Unknown Devices overview.
*	Currency columns aligned to right.

### Fixed
*	Fixed reversed upload / download speed values for "egress only" traffic shaping on AirOs devices.
*	Fixed crash after restoring database backup.
*	Fix GPS latitude / longitude scale.
*	Deleted Products and Sites are no longer visible in select boxes.
*	Fixed word wrapping of invoice labels.
*	Fixed timezone detection in the UCRM init wizard.
*	Fixed EdgeOs synchronization errors (including VLAN interface discovery).
*	Fixed manual service suspension with custom "stop reason".
*	Fixed crashes when resetting filters for some grids (such as resetting date filter for client's invoice grid).
*	Fixed missing phone in CSV import of clients.
*	The attempt to setup traffic shaping on AirOs device when no download / upload speed is set is now logged properly.
*	Stripe payments now fail gracefully when there is an error (e.g. when attempting to pay less then 50 cents).
*	Fixed device links in outage notification emails when HTTPS is enabled (note that the UCRM server port must be set to 443 in system settings).
*	Fixed searching by IPs of devices and CPEs and generally improved searching
*	Minor bug fixes and UI fixes

## 2.2.0 (2017-01-13)

### Added
*	New search bar added, accessible also with "/" slash keyboard shortcut. You can find clients, invoices, payments and even help articles using a key word such as client ID, email, IP address, invoice number, etc.
*	You can also search archived clients by name, address, service IP, etc.
* UCRM Dashboard redesigned, the most important information about billing and network added.
*	While setting up HTTPS, you can now upload the CA bundle file along with your cert file.
*	Information about client's payment subscriptions are shown in client detail page.
*	API enhanced. You can retrieve all clients and all services or get entities by their ID.
*	You can manually create and download up-to-date database backup (in System > Tools).
*	Old device backup files are pruned. Last 14 backups are kept in UCRM after each synchronization.

### Changed
*	Now, you can define tax value with up to 4 decimal digits.
*	SNMP community string limited to 32 chars.

### Fixed
*	Mailer spool fixed in case there is a mail pending with invoice PDF previously removed.
*	Fixed possible bug with connection to Elastic container after UCRM update.
*	Synchronization with older EdgeOs devices improved.
*	Client sorting by ID fixed.
*	Fixed automated NetFlow set up. (For some devices, the NetFlow could have remained in pending state.)
*	Minor bugs fixed.

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




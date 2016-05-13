# Changelog

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




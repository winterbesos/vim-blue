# vim-blue
For Blue Net

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)

## Installation

- vim-plug

```vim
Plug 'winterbesos/vim-blue'
```

dependencies:

[mattn/webapi-vim](https://github.com/mattn/webapi-vim)

## Configuration

Adding the following lines to your `vimrc` file.

```
let g:blue_token = '{YOUR_BIZ_SERVER_ACCESS_TOKEN}'
let g:blue_base_url = '{YOUR_BIZ_SERVER_BASE_URL}'
```

## Usage
```
:Border {ORDER_NO} "Query order info, and display it in new buffer.
:Bplan {ORDER_NO} "Query plan info, and display it in new buffer.
:Bstaff {USER_ID} "Query staff info, and display it in new buffer.
:Bcustomer {USER_ID} "Query customer info, and display it in new buffer.
:Borg {ORG_CODE} Query "org info, and display it in new buffer.
:Bjgorder {JG_ORDER_NO} "Query JG order info, and display it in new buffer.
:Bagencyorder {AGENCY_ORDER_NO} "Query courier task info, and display it in new buffer.
```
If the parameter not exists, it will query the `identifier` the cursor on.

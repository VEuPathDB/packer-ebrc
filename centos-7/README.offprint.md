
`source_website` must be the backend server that hosts apiSiteFilesMirror, not a a proxy.


`inventory`

    [source_webserver]
    # w1.foodb.org

    [buildhost]
    localhost               ansible_connection=local


`source_websever` is undefined in `inventory` and set on CLI.

    ansible-playbook -i inventory playbook.yml --extra-vars "source_website=w1.cryptodb.org" 



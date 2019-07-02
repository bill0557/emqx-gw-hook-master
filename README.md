
emqx-gw-hook
=============

EMQ X Gwhook plugin.

##### emqx_gw_hook.conf

```properties
gw.hook.api.url = http://127.0.0.1:8080

## Encode message payload field
## gw.hook.encode_payload = base64

gw.hook.rule.client.connected.1     = {"action": "on_client_connected"}
gw.hook.rule.client.disconnected.1  = {"action": "on_client_disconnected"}
```

API
----
* client.connected
```json
{
    "action":"client_connected",
    "client_id":"C_1492410235117",
    "username":"C_1492410235117",
    "keepalive": 60,
    "ipaddress": "127.0.0.1",
    "proto_ver": 4,
    "connected_at": 1556176748,
    "conn_ack":0
}
```

* client.disconnected
```json
{
    "action":"client_disconnected",
    "client_id":"C_1492410235117",
    "username":"C_1492410235117",
    "reason":"normal"
}
```


License
-------

Apache License Version 2.0

Author
------

* [Sakib Sami](https://github.com/s4kibs4mi)

Contributors
------------

* [Deng](https://github.com/turtleDeng)
* [vishr](https://github.com/vishr)
* [emqplus](https://github.com/emqplus)
* [huangdan](https://github.com/huangdan)


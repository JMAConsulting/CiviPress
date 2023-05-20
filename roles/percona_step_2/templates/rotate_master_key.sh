#!/bin/bash
mysql --login-path=rotate_key_user@localhost --execute="ALTER INSTANCE ROTATE INNODB MASTER KEY;"
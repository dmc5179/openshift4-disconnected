# Creating the AWS UPI infrastructure

- Create the security groups

```
./create_sg.sh
```

- Create the Load Balancers and Target Groups

```
create_infra.sh
```

- Create the DNS entries that point to the Load Balancers

```
route53.sh
```

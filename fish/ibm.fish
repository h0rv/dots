export PATH="/home/robby/.local/bin:$PATH"
export PATH="/home/robby/.cargo/bin:$PATH"
alias python3=/usr/bin/python3.11
alias pip3=/usr/bin/pip3.11
alias pip=pip3
alias python=python3

# ibmcloud cli
alias ic="ibmcloud"
alias login-dev="ibmcloud login -a cloud.ibm.com -sso -r us-south -c 779c0808c946b9e15cc2e63013fded8c"
alias login-fra="ibmcloud login -a cloud.ibm.com -sso -r us-south -c cad1cd992c9f2344b0785e4f0fed0669"
alias login-prod="ibmcloud login -a cloud.ibm.com -sso -r us-south -c a6677d241bbad8189145cbae0c73208f"
alias login-test="ibmcloud login -a test.cloud.ibm.com -sso -r us-south -c b5c4dad1451e4a959106fa955f26f57c"
alias login-dn="ibmcloud login -a cloud.ibm.com -sso -r us-south -c 45068c1e7bb0477bb18db9056e9b8049"

# terraform
alias tf="terraform"

# kube
alias k="kubectl"
kubectl completion fish | source

# teleport login
function tlogin
    tsh login "$argv[1]-bastion"; and tsh kube login "$argv[1]-bastion"
end

# bastion 
alias bastion-dev-south="tsh login --proxy c7k77avd03oqris1dps0-pa54tbh3zcvxwptdchf3.bastionx.cloud.ibm.com:443"
alias bastion-dev="tsh login --proxy 779c0808c946b9e15cc2e63013fded8c-hpyuu7vk.bastionx.cloud.ibm.com:443"
alias bastion-fscloud-east="tsh login --proxy c5nfi7kw0719jthsagng-ed6dqi1mezjohh9g4b42.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-fscloud-south="tsh login --proxy c5nflbpd0fqjf8b7e49g-oewu2zqqvvdk3hhnx868.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-bnpp-1="tsh login --proxy cf98q9hb0hirlokil2hg-vx3cwafpo6dohmew1e2f.bastionx.cloud.ibm.com:443"
alias bastion-bnpp-2="tsh login --proxy cf4nobkb0m9n8cm20odg-qe1dyhv7xfrbtf874ipk.bastionx.cloud.ibm.com:443"
alias bastion-fra-1="tsh login --proxy caaece0f0vi622762an0-5kcx9uuzktxwht1p1a4a.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-fra-2="tsh login --proxy cab1h43f0d6qvg3ut15g-azgtdpxpgw5w31xq44sk.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-syd="tsh login --proxy cal1u15s04pdfmfsgmo0-67t8c9mxyeqqhka8oz7o.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-sao="tsh login --proxy cal4oqiz06tqnsht6cd0-st1sckq3fwjhonpay0va.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-tor="tsh login --proxy cal43cgr0pf6cfga4h9g-7gk64hf4b4yz4egkojtv.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-lon="tsh login --proxy calivinl0jllp4aq84eg-1zbvq3pxhtnz0iosv3t6.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-osa="tsh login --proxy caljp0vo058hpuhvb180-g1rz1nqn6erwyajy0aig.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-tok="tsh login --proxy calkmlmt0kg4tpi14hbg-1k78yupn9fixv04eipfd.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-wdc="tsh login --proxy callajqw08iqtc24aa4g-gagodr0wfttk0xdvu7wb.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod-dal="tsh login --proxy callvjed0hjc349s8po0-g5azs4jnjwniere2kqff.bastionx.cloud.ibm.com:443 --request-reason"
alias bastion-prod="tsh login --proxy a6677d241bbad8189145cbae0c73208f-c1tfb5ux.bastionx.cloud.ibm.com:443 --request-reason"

# npm fix
npm set prefix ~/.npm
export PATH="$HOME/.npm/bin:$PATH"
export PATH="./node_modules/.bin:$PATH"

grit-debug -- --completion fish | source

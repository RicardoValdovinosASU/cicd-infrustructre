import os
import re
import subprocess
import sys


def read_terraform_output():
    with open('../terraform/output', 'r') as f:
        terraform_output = f.read()
    return terraform_output


def get_aws_public_ip(terraform_output):
    terraform_output_list = terraform_output.split('public_ip')
    aws_public_ip = terraform_output_list[1].replace('=', '').strip()
    return aws_public_ip


def remove_esc_seq(input_string):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', input_string)


def write_new_ip_to_ansible_hosts(aws_public_ip):
    with open('/etc/ansible/hosts', 'w') as f:
        update = remove_esc_seq(f'''[webserver]\n{aws_public_ip}''')
        f.write(update)


def delete_output_file():
    subprocess.run(['rm', '../terraform/output'])


def main():
    terraform_output = read_terraform_output()
    aws_public_ip = get_aws_public_ip(terraform_output)
    write_new_ip_to_ansible_hosts(aws_public_ip)
    delete_output_file()


if __name__ == "__main__":
    main()

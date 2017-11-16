#!/usr/bin/env python2

#
# Autostop EC2 Lambda POC script.
# xmanning - 2017
#

from __future__ import print_function
import boto3
from datetime import datetime

# Poweroff time (24h format)
poweroff_time = 2000

# Set to false if we aren't debugging on a local machine.
local_debug = False

# StopEC2 Object
class StopEC2:
    # initialize required EC2 client and configuration
    def __init__(self):
        self.init_client = boto3.client('ec2')
        self.ec2_client = {}
        self.instance_stop_list = {}
        self.now = datetime.now()
        self.time = int(self.now.strftime('%H%M'))

    # Return a list of regions
    def list_regions(self):
        regions = []
        for region_info in self.init_client.describe_regions()['Regions']:
            regions.append(region_info['RegionName'])
        return regions

    def create_regions_ec2_clients(self):
        for region in self.list_regions():
            self.instance_stop_list[region] = []
            self.ec2_client[region] = boto3.client('ec2', region_name=region)

    def destroy_regions_ec2_clients(self):
        for region in self.list_regions():
            self.ec2_client[region] = None

    def list_ec2s_per_region(self):
        print('================================================')
        print('  Scanning Regions for stoppable EC2 instances  ')
        print('================================================')
        print('')
        print('Key:')
        print('  +  EC2s with AutoStop Tag')
        print('  -  EC2s to be ignored')
        print('')
        self.create_regions_ec2_clients()
        for region in self.list_regions():
            print('------------------------------------------------')
            print('EC2s running in {}'.format(region))
            print('------------------------------------------------')
            for reservation in self.ec2_client[region].describe_instances()['Reservations']:
                for instance in reservation['Instances']:
                    if instance['State']['Name'] == 'running':
                        name = "No Name"
                        autostop = '-'
                        if 'Tags' in instance:
                            for tag in instance['Tags']:
                                if tag['Key'] == 'Name':
                                    name = tag['Value']
                                if tag['Key'] == 'AutoStop' and tag['Value'] == 'True':
                                    autostop = '+'
                                    self.instance_stop_list[region].append(instance['InstanceId'])
                        print('  {}  {} ({})'.format(autostop, instance['InstanceId'], name))
            print('')
        print('Done')
        print('')

    def stop_instances(self):
        print('')
        print('================================================')
        print('            Running Stop Proceedure!')
        print('================================================')
        print('')
        for region in self.list_regions():
            if len(self.instance_stop_list[region]) > 0:
                print('------------------------------------------------')
                print('Stopping: {}'.format(self.instance_stop_list[region]))
                print('------------------------------------------------')
                self.ec2_client[region].stop_instances(InstanceIds=self.instance_stop_list[region])
        print('Done')
        self.destroy_regions_ec2_clients()



def lambda_handler(event, context):
    client = StopEC2()
    if client.time >= poweroff_time:
        client.list_ec2s_per_region()
        client.stop_instances()
    else:
        print('It is not power off time! (>={})'.format(poweroff_time))

if __name__ == '__main__' and local_debug == True:
    lambda_handler([],[])

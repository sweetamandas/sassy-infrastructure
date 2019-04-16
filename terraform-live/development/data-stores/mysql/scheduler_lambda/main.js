const AWS = require('aws-sdk');
const util = require('util');

const rds = new AWS.RDS();

exports.handler = async (event) => {
  const action = event.action;

  for (let instanceId of event.instances) {

    const params = {
      DBInstanceIdentifier: instanceId
    };


    if (action === 'stop') {
      console.log(`stopping instance '${instanceId}'...`);
      await util.promisify(rds.stopDBInstance.bind(rds))(params);
    }
    else if (action === 'start') {
      console.log(`starting instance '${instanceId}'...`);
      await util.promisify(rds.startDBInstance.bind(rds))(params);
    }
    else {
      throw new Error(`Invalid action: ${action}`);
    }

    console.log('done');
  }
};


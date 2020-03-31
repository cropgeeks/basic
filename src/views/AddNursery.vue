<template>
  <b-container class="container-top">
    <h1>Add Nursery</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Nurseries" :items="nurseries"></b-table>
          <p v-if="nurseries.length === 0">No nurseries found</p>
        </div>

        <b-button v-b-modal.addModal class="float-left" variant="primary">Add nursery</b-button>
        <b-modal id="addModal" title="Add nursery" @ok="addNursery">
          <b-form>
            <b-form-group label="Owner" label-for="nursery-owner" label-align="left">
              <b-form-select id="nursery-owner" size="sm" :options="options" v-model="nurseryOwner"></b-form-select>
            </b-form-group>
            <b-form-group label="Name" label-for="nursery-name" label-align="left">
              <b-input id="nursery-name" size="sm" placeholder="Name" v-model="nurseryName"/>
            </b-form-group>
            <b-form-group label="Latitude" label-for="nursery-lat" label-align="left">
              <b-input id="nursery-lat" size="sm" placeholder="0" type="number" step="0.01" min="-90" max="90" v-model="nurseryLat"/>
            </b-form-group>
            <b-form-group label="Longitude" label-for="nursery-long" label-align="left">
              <b-input id="nursery-long" size="sm" placeholder="0" type="number" step="0.01" min="-180" max="180" v-model="nurseryLong"/>
            </b-form-group>
            <b-form-group label="Description" label-for="nursery-desc" label-align="left">
              <b-input id="nursery-description" type="text" size="sm" placeholder="Nursery description" v-model="nurseryDesc"/>
            </b-form-group>
          </b-form>
        </b-modal>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'

export default {
  name: 'home',
  data() {
    return {
      nurseries: [],
      nurseryName: null,
      nurseryLat: null,
      nurseryLong: null,
      nurseryDesc: null,
      nurseryOwner: null,
      owners: []
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.nurseryManager.deployed().then((contract) => {
      this.nurseries = this.getNurseries(contract);
      this.setupNurseryAddedEvent(contract);
      this.owners = this.getNurseryOwners(contract);
      })
    })
  },
  computed: {
    options: function() {
      const opts = [];
      this.owners.forEach((owner) => {
        opts.push({ value: owner, text: owner.name})
      })
      return opts;
    }
  },
  methods: {
    addNursery: function() {
      this.nurseryManager.deployed().then((contract) => {
        //string memory name, int lat, int long, string memory nurseryDescription, address nurseryOwner
        contract.addNursery(this.nurseryName, this.nurseryLat, this.nurseryLong, this.nurseryDesc, this.nurseryOwner.address);
      }).catch(error => {
        // TODO: Flag to the user in some useful way
        console.log(error);
      }).then(() => {
        // We want to blank out our form fields whether we succeeded or failed
        // hence the placement in a then after the catch
        this.nurseryName = null;
        this.nurseryLat = null;
        this.nurseryLong = null;
        this.nurseryDesc = null;
        this.nurseryOwner = null;
      })
    },
    // Setup the event listener which checks for the addition of new nurseries
    setupNurseryAddedEvent: function(contract) {
      contract.AddedNursery().on('data', event => {
        let n = {
          id: event.returnValues.nurseryId,
          name: event.returnValues.nurseryName,
          lat: event.returnValues.lat,
          long: event.returnValues.long,
          description: event.returnValues.description,
          owner: event.returnValues.ownerName
        }

        this.nurseries.push(n);
      });
    },
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>

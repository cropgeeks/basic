<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
    <h1>Add Farm</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Farms" :items="farms"></b-table>
          <p v-if="farms.length === 0">No farms found</p>
        </div>

        <b-button v-b-modal.addModal class="float-left" variant="primary">Add farm</b-button>
        <b-modal id="addModal" title="Add farm" @ok="addFarm">
          <b-form>
            <b-form-group label="Owner" label-for="farm-owner" label-align="left">
              <b-form-select id="farm-owner" size="sm" :options="options" v-model="farmOwner"></b-form-select>
            </b-form-group>
            <b-form-group label="Name" label-for="farm-name" label-align="left">
              <b-input id="farm-name" size="sm" placeholder="Name" v-model="farmName"/>
            </b-form-group>
            <b-form-group label="Latitude" label-for="farm-lat" label-align="left">
              <b-input id="farm-lat" size="sm" placeholder="0" type="number" step="0.01" min="-90" max="90" v-model="farmLat"/>
            </b-form-group>
            <b-form-group label="Longitude" label-for="farm-long" label-align="left">
              <b-input id="farm-long" size="sm" placeholder="0" type="number" step="0.01" min="-180" max="180" v-model="farmLong"/>
            </b-form-group>
            <b-form-group label="Description" label-for="farm-desc" label-align="left">
              <b-input id="farm-description" type="text" size="sm" placeholder="Farm description" v-model="farmDesc"/>
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
      farms: [],
      farmName: null,
      farmLat: null,
      farmLong: null,
      farmDesc: null,
      farmOwner: null,
      owners: [],
      breadcrumbs: [
        {
          text: "Admin",
          to: { name: 'admin' }
        },
        {
          text: "Farms",
          active: true
        }
      ]
    }
  },
  mounted() {
     web3.eth.getAccounts().then(() => {
      // Specific setup of elements for this page
      this.farmManager.deployed().then((contract) => {
        this.farms = this.getFarms(contract);
        this.owners = this.getFarmOwners(contract);
        this.setupFarmAddedEvent(contract);
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
    addFarm: function() {
      this.farmManager.deployed().then((contract) => {
        contract.addFarm(this.farmName, this.farmLat, this.farmLong, this.farmDesc, this.farmOwner.address);
      }).catch(error => {
        // TODO: Flag to the user in some useful way
        console.log(error);
      }).then(() => {
        // We want to blank out our form fields whether we succeeded or failed
        // hence the placement in a then after the catch
        this.farmName = null;
        this.farmLat = null;
        this.farmLong = null;
        this.farmDesc = null;
        this.farmOwner = null;
      })
    },
    // Setup the event listener which checks for the addition of new farms
    setupFarmAddedEvent: function(contract) {
      contract.AddedFarm().on('data', event => {
        let n = {
          id: event.returnValues.farmId,
          name: event.returnValues.name,
          lat: event.returnValues.lat,
          long: event.returnValues.long,
          description: event.returnValues.description,
          owner: event.returnValues.ownerName
        }

        this.farms.push(n);
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

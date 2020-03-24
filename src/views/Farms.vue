<template>
  <b-container class="container-top">
    <h1>Nurseries</h1>
    <div class="row">
      <b-card-group deck v-for="farm in farms" v-bind:key="farm.id">
        <b-card
          :title="farm.name"
          img-src="~@/assets/raspberries-small.jpg"
          :img-alt="farm.name"
        >
          <b-card-text>
            {{ farm.description }}
          </b-card-text>
          <b-button @click="$router.push({ name: 'farm', params: { farmId: farm.id }})" variant="primary">
            View
          </b-button>
        </b-card>
      </b-card-group>
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
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.supplyContract.deployed().then((contract) => {
        this.farms = this.getFarms(contract);
        this.setupFarmAddedEvent(contract);
      })
    })
  },
  methods: {
    // TODO: this code is duplicated from AddFarm page...think about best way
    // to eliminate code duplication
    // Setup the event listener which checks for the addition of new nurseries
    setupFarmAddedEvent: function(contract) {
      contract.AddedFarm().on('data', event => {
        let farm = {
          id: event.returnValues.farmId,
          name: event.returnValues.farmName,
          lat: event.returnValues.lat,
          long: event.returnValues.long,
          description: event.returnValues.description,
          owner: event.returnValues.ownerName
        }

        this.farms.push(farm);
      });
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
.card-header{
  background-color: rgba(0, 0, 0, 0.000000001);
  border-bottom: 0px;
}
</style>

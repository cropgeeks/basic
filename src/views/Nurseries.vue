<template>
  <b-container class="container-top">
    <h1>Nurseries</h1>
    <div class="row">
      <b-card-group deck v-for="nursery in nurseries" v-bind:key="nursery.id">
        <b-card
          :title="nursery.name"
          img-src="~@/assets/plantnursery.jpg"
          :img-alt="nursery.name"
        >
          <b-card-text>
            {{ nursery.description }}
          </b-card-text>
          <b-button @click="$router.push({ name: 'nursery', params: { nurseryId: nursery.id }})" variant="primary">
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
      nurseries: [],
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.supplyContract.deployed().then((contract) => {
        this.nurseries = this.getNurseries(contract);
        this.setupNurseryAddedEvent(contract);
      })
    })
  },
  methods: {
    // TODO: this code is duplicated from AddNursery page...think about best way
    // to eliminate code duplication
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

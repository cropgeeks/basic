<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
    <h1>Nursery</h1>
    <div class="row" v-if="nursery !== null">
      <div class="col">
        <div class="row">
          <h2>{{ nursery.name }}</h2>
        </div>
        <div class="row">
          <p>{{ nursery.description }}</p>
        </div>
        <div class="row">
          <b-card-group deck>
            <b-card
              title="Propogated"
              img-src="~@/assets/plantnursery.jpg"
              img-alt="propogated plants"
            >
              <b-button @click="$router.push({ name: 'nursery-propogated', params: { nurseryId: nursery.id }})" varaint="primary">View propogated</b-button>
            </b-card>
            <b-card
              title="Orders"
              img-src="~@/assets/raspberries-small.jpg"
              img-alt="orders"
            >
              <b-button @click="$router.push({ name: 'nursery-orders', params: { nurseryId: nursery.id }})" varaint="primary">View orders</b-button>
            </b-card>
          </b-card-group>
        </div>
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
      nursery: null,
       breadcrumbs: [
        {
          text: "Home",
          to: { name: 'home' }
        },
        {
          text: "Nurseries",
          to: { name: 'nurseries' }
        },
        {
          text: "Nursery",
          active: true
        }
      ]
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      // Handle account changes
      // web3.currentProvider.publicConfigStore.on('update', (update) => {
      //   const newAddress = update.selectedAddress;
      //   this.defaultAccount = newAddress;
      //   web3.eth.defaultAccount = newAddress;
      //   this.supplyContract.defaults({from: this.w3.eth.defaultAccount})
      // });

      this.nurseryManager.deployed().then((contract) => {
        this.initNursery(contract);

        // Check if the selected account is the nursery owner
        contract.isNurseryOwner(this.$route.params.nurseryId).then(isOwner => {
          this.isNurseryOwner = isOwner;
        })
      })
    })
  },
  methods: {
    initNursery: function(contract) {
      // Retrieve nursery info
      contract.getNursery(this.$route.params.nurseryId).then((n) => {
        this.nursery = {
          id: n[0].toNumber(),
          name: n[1].toString(),
          lat: n[2].toNumber(),
          long: n[3].toNumber(),
          description: n[4].toString(),
          ownerName: n[5].toString(),
          ownerAddress: n[6].toString()
        }
      })
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

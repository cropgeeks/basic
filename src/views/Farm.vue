<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
    <h1>Farm</h1>
    <div class="row" v-if="farm !== null">
      <div class="col">
        <div class="row">
          <h2>{{ farm.name }}</h2>
        </div>
        <div class="row">
          <p>{{ farm.description }}</p>
        </div>
        <div class="row">
          <b-card-group deck>
            <b-card
              title="Planted"
              img-src="~@/assets/plantnursery.jpg"
              img-alt="plant nursery"
            >
              <b-button @click="$router.push({ name: 'farm-planted', params: { farmId: farm.id }})" varaint="primary">View planted</b-button>
            </b-card>
            <b-card
              title="Orders"
              img-src="~@/assets/raspberries-small.jpg"
              img-alt="orders"
            >
              <b-button @click="$router.push({ name: 'farm-orders', params: { farmId: farm.id }})" varaint="primary">View orders</b-button>
            </b-card>
            <b-card
              title="Storage"
              img-src="~@/assets/raspberry-punnets.jpg"
              img-alt="storage"
            >
              <b-button @click="$router.push({ name: 'farm-storage', params: { farmId: farm.id }})" varaint="primary">View store</b-button>
            </b-card>
            <b-card
              title="Employees"
              img-src="~@/assets/role-icon.png"
              img-alt="employees"
            >
              <b-button @click="$router.push({ name: 'farm-employees', params: { farmId: farm.id }})" varaint="primary">View employees</b-button>
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
      farm: null,
      breadcrumbs: [
        {
          text: "Home",
          to: { name: 'home' }
        },
        {
          text: "Farms",
          to: { name: 'farms'}
        },
        {
          text: "Farm",
          active: true
        }
      ]
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.farmManager.deployed().then((contract) => {
        this.initFarm(contract);

        contract.isFarmOwner(this.$route.params.farmId).then(isFarmer => {
          this.isFarmOwner = isFarmer;
        })
      })
    })
  },
  methods: {
    initFarm: function(contract) {
      // Retrieve farm info
      contract.getFarm(this.$route.params.farmId).then((f) => {
        this.farm = {
          id: f[0].toNumber(),
          name: f[1].toString(),
          lat: f[2].toNumber(),
          long: f[3].toNumber(),
          description: f[4].toString(),
          ownerName: f[5].toString(),
          ownerId: f[6].toString()
        }
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>

<template>
  <div class="container container-top">
    <b-container>
      <h1>Nurseries</h1>
      <b-list-group>
        <b-list-group-item v-for="nursery in nurseries" v-bind:key="nursery.id" class="text-left">
          <p>Name: {{ nursery.name }}</p>
          <p>Latitude: {{ nursery.lat }}</p>
          <p>Longitude: {{ nursery.long }}</p>
        </b-list-group-item>
      </b-list-group>
      <h1>Plant list</h1>
      <b-list-group>
        <b-list-group-item v-for="plant in plants" v-bind:key="plant.id" class="text-left">
          <p>Id: {{ plant.id }}</p>
          <p>State: {{ states.find(p => p.value === plant.state).text }}</p>
          <p>Planted date: {{ plant.plantedDate }}</p>
          <p>Latitude: {{ plant.lat }}</p>
          <p>Longitude: {{ plant.long }}</p>
          <p>Nursery: {{ plant.nursery }}</p>
        </b-list-group-item>
      </b-list-group>
    </b-container>
  </div>

</template>

<script>
import web3 from '../util/getWeb3'

export default {
  name: 'home',
  data() {
    return {
      nurseries: [],
      plants: [],
      states: [
        { value: 0, text: "Planted"},
        { value: 1, text: "Harvested"},
        { value: 2, text: "Weighted"}
      ],
      show: true
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.supplyContract.deployed().then((contract) => {
        contract.getNurseryCount().then((count) => {
          for (var i = 0; i < count; i++) {
            contract.getNursery(i).then((nursery) => {
              this.addNursery(nursery);
            })
          }
        })
      })
    })
  },
  methods: {
    addPlant: function(plant) {
      let p = {
        id: plant[0].toNumber(),
        state: plant[1].toNumber(),
        plantedDate: new Date(plant[2].toNumber() * 1000),
        lat: plant[3].toNumber(),
        long: plant[4].toNumber(),
        nursery: plant[5].toString()
      }

      this.plants.push(p)
    },
    addNursery: function(nursery) {
      let n = {
        id: nursery[0].toNumber(),
        name: nursery[1].toString(),
        lat: nursery[2].toNumber(),
        long: nursery[3].toNumber()
      }

      this.nurseries.push(n);
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

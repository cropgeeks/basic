<template>
  <b-container class="container-top">
    <h1>Home</h1>
    <b-card-group deck class="mt-3">
      <b-card
        title="Nursery"
        img-src="~@/assets/plantnursery.jpg"
        img-alt="plant nursery"
      >
        <b-button to="nurseries" varaint="primary">Nurseries</b-button>
      </b-card>
      <b-card
        title="Farm"
        img-src="~@/assets/raspberries-small.jpg"
        img-alt="farm"
      >
        <b-button to="farms" varaint="primary">Farms</b-button>
      </b-card>
      <b-card
        title="Plants"
        img-src="~@/assets/raspberry-plant.jpg"
        img-alt="plants"
      >
        <b-button to="plants" varaint="primary">Plants</b-button>
      </b-card>
    </b-card-group>
  </b-container>

</template>

<script>

export default {
  name: 'home',
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
